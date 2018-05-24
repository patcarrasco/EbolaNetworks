library(igraph)
library(tidyverse)
library(gam)
library(ggthemes)


# set seed if wanting to comapre against common data...
# set.seed(9999)



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# ------------------- Parameters that can change -------------------------

N = 1000 # size of the population

initial_num_infected = .01 * N
infection_rate_from_infected = 0.1
infection_rate_from_corpse = 0.2 # 
case_fatality_rate = 0.65  # case fatality # effect on infected --> recovery // Default CFR is .65
amt_doctors_in_network = seq(0.01 * N , 0.1 * N , by = 0.01 * N) # amount of doctors in the network


x_param = amt_doctors_in_network # <----------------------------------------- ENTER the Parameter currently tested 
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# ------------------- Parameters that won't change
timestep = 100 # per iteration
iterations = 100
sw_nei = 5 # neighbors for the SmallWorld, set to 5 b/c avg houshold in sierra leone is 6 people

# ------------------- Set up tables for data collection
full_stats = tibble()
life_stats = tibble()

complete_counts = tibble()

# 
# ---------------------------------- Multiple Iteration Start --------------------------------
# 

for (sim in 1:iterations) {
  
  for (iter in seq_along(x_param)) { # Start multiple iterations
    
    
    # Set up testing params  
    #  Will need to add [iter] to end of what is being tested!!!!
    initial_infected = initial_num_infected
    infection_rate_corpse = infection_rate_from_corpse
    infection_rate = infection_rate_from_infected
    CFR = case_fatality_rate 
    amt_doctors = amt_doctors_in_network[iter]
    
    # ------------------ Setting up Network  ------------
    g <- sample_smallworld(size = N, dim = 1, nei = sw_nei, p = 0.05)
    
    # ------------------ Setting up the empty agent attributes ------------
    g <- set.vertex.attribute(g, 'class', value = NA) # either NA or doctor
    #g <- set.vertex.attribute(g, 'influence', value = NA) # degree / max degree of whole network
    g <- set.vertex.attribute(g, 'health', value = NA) # healthy , infected, dead, recovered, exposed
    g <- set.vertex.attribute(g, 'case_count', value = NA)
    g <- set.vertex.attribute(g, 'dead_count', value = NA)
    
    
    # ------------------ Set Up Status of Individuals  ------------------
    
    # set up normal individuals
    cit_pos = sample(V(g))
    V(g)$col[cit_pos] = 'green'
    V(g)$health[cit_pos] = 'healthy'
    
    
    # set up the sick individual
    sick_pos = sample(cit_pos, size = initial_infected)
    V(g)$health[sick_pos] = 'infected'
    V(g)$col[sick_pos] = 'red'
    
    # set up the doctor
    doc_pos = sample(cit_pos, size = amt_doctors)
    V(g)$class[doc_pos] = 'doctor'
    V(g)$col[doc_pos] = 'purple'
    
    par(mfrow = c(1,1))
    
    #plot(g, layout = layout.kamada.kawai, vertex.color = V(g)$col,
    #     vertex.label = '', vertex.shape = 'circle', vertex.size = 4)
    
    # ------------------ New plot to compare old to new
    
    p <- g
    
    # ------------------ Setting up dict with initial infected ---------------
    patient_0 = which(V(p)$health == 'infected')
    
    dead_book = matrix(ncol = 2, nrow = length(V(p)))
    for (i in 1:length(patient_0)) {
      dead_book[patient_0[i],1] = patient_0[i]
      dead_book[patient_0[i],2] = 2
    }
    # ------------------ Setting up dict to record exposed through timesteps -------
    exposed_book = matrix(ncol = 2, nrow = length(V(p)))
    
    # Next we set the movement within the network 
    
  
    # ---------------- Set up tables for data collection ---------------------
    
    
    # Numbers of S, I, R, E, D at each time step
    sick_monitor = tibble(S = N - initial_infected, I = initial_infected,E = 0, R = 0, D = 0, Timestep = 1)
    
    # Calculted Network information at each time step
    E_stats = tibble(coef = transitivity(p), time = 1, cluster = count_components(p), 
                     max_degree = max(degree(p)), assortativity = assortativity_degree(p), diameter = diameter(p),
                     Number_of_P0 = initial_infected, infection_rate_corpse = infection_rate_corpse,
                     infection_rate = infection_rate, CFR = CFR, amt_doctors = amt_doctors, sim = sim)
    
    # Cumulative deaths / cases at each time step
    life_counts = tibble(cases = initial_infected, deaths = 0, time = 1, 
                         Number_of_P0 = initial_infected, 
                         infection_rate_corpse = infection_rate_corpse,
                         infection_rate = infection_rate, CFR = CFR, amt_doctors = amt_doctors, sim = sim)
    
    
    
    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    # ----------------------------------- Start of Single Model -------------------------------------------
    
    for (t in 2:timestep) { # Start Single run
      
      
      # RECORD STATS OF THE NETWORK 
      E_stats <- E_stats %>%
        add_row(coef = transitivity(p),
                cluster = count_components(p),
                time = t,
                max_degree = max(degree(p)),
                assortativity = assortativity_degree(p),
                diameter = diameter(p), Number_of_P0 = initial_infected, infection_rate_corpse = infection_rate_corpse,
                infection_rate = infection_rate, CFR = CFR, amt_doctors = amt_doctors, sim = sim)
      
      sick_monitor <- sick_monitor %>%
        add_row(S = length(which(V(p)$health == 'healthy')),
                I = length(which(V(p)$health == 'infected')),
                R = length(which(V(p)$health == 'recovered')),
                E = length(which(V(p)$health == 'exposed')),
                D = length(which(V(p)$health == 'dead')),
                Timestep = t)
      
    
      # ------------------ Set up counters for exposed and dead
      
      V(p)[V(p)]$case_count = NA
      V(p)[V(p)]$dead_count = NA
      
      
      #------------------------------------------- Movements --------------------------------------------------
      
      
      # ------------------ DOCTOR ACTION -----------
      # Is near a infected??
      
      
      tryCatch({ # Helps me find and diagnose error if it happens
        
      doc = which(V(p)$class == 'doctor')
      if (length(doc) != 0) {
      possible_patients = neighbors(p, doc)
      infected_patients_TRUE = which(V(p)$health[possible_patients] == 'infected')
      infected_patients_TRUE = sample(V(p)[infected_patients_TRUE])
      if (length(infected_patients_TRUE) != 0) { # if the doctor is connected to an infected patient
        doc_patients = possible_patients[infected_patients_TRUE] # <------- I identify the neighboring sick Agents
      } 
      
      all_sick_peoples = which(V(p)$health == 'infected')
      all_sick_peoples = sample(V(p)[all_sick_peoples])
      if (length(all_sick_peoples) != 0) {
        chosen_sick = which(V(p)$health == 'infected')
        for (i in 1:length(doc)) {
          a_sick_person = sample(V(p)[chosen_sick], size = 1)
          add_edges(p, c(doc[i], a_sick_person))}
        }
      
      
      
      
      # does doc heal anyone??
      if (length(infected_patients_TRUE) != 0) {
        for (patient in length(doc_patients)) {
          grim_reaper = sample(1:100, size = 1) # picks a random number
          if (grim_reaper %% 2 == 0) { # if even, patient is cured as recover is often 50-50 (from CDC)
            V(p)$health[doc_patients[patient]] = 'recovered'
            V(p)$col[doc_patients[patient]] = 'cyan' 
          } else {}}}
      }
      }, error=function(e){cat("ERROR in DOC:",conditionMessage(e), "\n")})
      
      
      #---------------- Latency period checked for individuals -----------
      exposed = which(V(p)$health == 'exposed')
      
      if (length(exposed) != 0) {
        for (e in 1:length(exposed)){
          if (exposed[e] %in% exposed_book[,1]) {
            z = which(exposed_book[,1] == exposed[e])
            time_in_E = exposed_book[z,2]
            if (time_in_E == 8) { # Latency of 8 days for Ebola (from CDC)
              if (V(p)$health[exposed[e]] == 'exposed' ){
                exp_ind = exposed_book[z,1]
                if(V(p)$health[exp_ind] != 'dead') {
                  V(p)$health[exp_ind] = 'infected'
                  V(p)$col[exp_ind] = 'red'
                  V(p)$case_count[exp_ind] = 'in'
                }} else {}
            } else {
              exposed_book[z,2] <- time_in_E + 1
            }} else {
              new_val <- exposed[e]
              exposed_book[new_val, 1] = new_val
              exposed_book[new_val, 2] = 1
            }}}
      
      
      # ----------- Check who is infected at start of this new turn + length of time infected / if death happens -------------
      
      infected = which(V(p)$health == 'infected')
      
      if (length(infected) != 0) {
        for (po in 1:length(infected)) {
          if (infected[po] %in% dead_book[,1]) {
            x = which(dead_book[,1] == infected[po])
            time_in_I = dead_book[x,2]
            if (time_in_I == 3) { # after 3 days of symptoms, 30% of people who survive are recovered by now (taken from infographic CDC)
              R_ind = dead_book[x,1]
              if (V(p)$health[R_ind] == 'infected') {
                immune_sys = sample(seq(0,1,by = 0.01), size = 1)
                if (immune_sys < .10){ # 30% of survivors feel better by now, there is a .1 probability of this happening at CFR of .65
                  V(p)$health[R_ind] = 'recovered'
                  V(p)$col[R_ind] = 'cyan'
                }}}
            if (time_in_I > 3) { # if time in infected past 3 days, death rate begins to factor into survival prob
              l_ind = dead_book[x,1]
              if (V(p)$health[l_ind] == 'infected') {
                dead_dice = sample(seq(0,1,by = 0.01), size = 1)
                if (dead_dice < CFR){
                  V(p)$health[l_ind] = 'dead'
                  V(p)$col[l_ind] = 'black'
                  V(p)$dead_count[l_ind] = 'in'
                }}}
            if (time_in_I == 8) { # if in infected w/ symptoms for 8 days, assume that death occurs (from CDC)
              I_ind = dead_book[x,1]
              if (V(p)$health[I_ind] == 'infected') {
                V(p)$health[I_ind] = 'dead'
                V(p)$col[I_ind] = 'black' 
                V(p)$dead_count[I_ind] = 'in'
              }}   
            dead_book[x,2] <- time_in_I + 1   
          } else {
            new_ind = infected[po]
            dead_book[new_ind,1] = new_ind
            dead_book[new_ind,2] = 1 # 
          }}}
      
      #------------------------- Infected person infects someone here --------- 
      
      tryCatch({ # There were rare instances of neighbors being unable to be found when model is run 100+ iterations, this prevents from crashing / helps me diagnose issue
        infected = which(V(p)$health == 'infected')
        
        if (length(infected) != 0) {
        susceptible_neighbors = neighbors(p, infected)
        new_sick = sample(susceptible_neighbors)
        new = which(V(p)[new_sick]$health == 'healthy')
        new_sick = new_sick[new]
        if (length(new_sick) != 0) {
          for (d in 1:length(new_sick)) {
            grim_dice = sample(seq(0,1,by = 0.01), size = 1)
            if (grim_dice < infection_rate) { # if random # generated is below input infection rate, then infection occurs
              if (V(p)$health[new_sick[d]] != 'dead' | V(p)$health[new_sick[d]] != 'recovered') { # just to make sure....
                V(p)$health[new_sick[d]] = 'exposed'
                V(p)$col[new_sick[d]] = 'yellow'
              }}}}
        }}, error=function(e){cat("ERROR in infected:",conditionMessage(e), "\n")})
      
      
      # -------------------- Dead person infecting someone -----------
      
      tryCatch({   # same as above
        dead = which(V(p)$health == 'dead')
        if (length(dead) != 0 ) {
        close_to_body = neighbors(p, dead)
        dead_b = sample(close_to_body)
        new_d = which(V(p)[dead_b]$health == 'healthy')
        dead_b = dead_b[new_d]
        if (length(dead_b) > 0) {
          for (q in 1:length(dead_b)) {
            grim_dice = sample(seq(0,1,by = 0.01), size = 1)
            if (grim_dice < infection_rate_corpse) { # Infection from corpse, similar method to infection above
              V(p)$health[dead_b[q]] = 'exposed'
              V(p)$col[dead_b[q]] = 'yellow'
            }}}}
      }, error=function(e){cat("ERROR in dead:",conditionMessage(e), "\n")})
      
      
      # Count who is in dead BEFORE deleting verts
      
      life_counts <- life_counts %>%
        add_row(cases = life_counts$cases[t-1] + (length(which(V(p)$case_count == 'in'))),
                deaths = life_counts$deaths[t-1] + (length(which(V(p)$dead_count == 'in'))),
                time = t,
                Number_of_P0 = initial_infected, infection_rate_corpse = infection_rate_corpse,
                infection_rate = infection_rate, CFR = CFR, amt_doctors = amt_doctors, sim = sim)
      
      
      
      #------------------- Bury the dead (remove from network) ----------------------
     delete = which(V(p)$health == 'dead')
     if (length(delete) > 0) { 
        p <- delete.vertices(p, c(V(p)[delete]))
        } 
      
    } # End single run
    
    full_stats = rbind(full_stats, E_stats)
    life_stats = rbind(life_stats, life_counts)
    
    
    
  } # End simulations
  
} # End multiple iterations
 
#----------------------------------------- END OF MODEL -----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# set tested variables to characters
life_stats$Number_of_P0 = as.character(life_stats$Number_of_P0)
life_stats$infection_rate_corpse = as.character(life_stats$infection_rate_corpse)
life_stats$infection_rate = as.character(life_stats$infection_rate)
life_stats$CFR = as.character(life_stats$CFR)
life_stats$amt_doctors = as.character(life_stats$amt_doctors)
full_stats$amt_doctors = as.character(full_stats$amt_doctors)


# -------------------- Plots

par(mfrow = c(1,1))
#plot(p, layout = layout.fruchterman.reingold, vertex.color = V(p)$col,
#     vertex.label = '', vertex.shape = 'circle', vertex.size = 3)


ggplot(data = full_stats, mapping = aes(x = diameter, y = amt_doctors)) +
  geom_jitter(size = .1, aes(color = amt_doctors)) +
  xlab('Network Diameter') +
  ylab('Initial # Doctors') +
  theme_base() +
  #scale_colour_colorblind() +
  guides(color = F) +
  scale_x_continuous(breaks = pretty(full_stats$diameter, n = 8))

# Death plot
ggplot(data = life_stats, mapping = aes(x = time, y = deaths, color = amt_doctors)) +
  #geom_jitter(size = 0.01) +
  geom_smooth(data = filter(life_stats, deaths != 0), se = F, size = 1.5) +
  xlab('Timestep') +
  ylab('Average Deaths') +
  labs(color = "Initial # Doctors") +
  theme_base() +
  guides(colour = guide_legend(override.aes = list(size=7)))



# Case plot
ggplot(data = life_stats,mapping = aes(x = time, y = cases, color = amt_doctors)) +
  #geom_jitter(size = 0.1) +
  geom_smooth(data = filter(life_stats, cases != 10), se = F, size = 1.5) +
  xlab('Timestep') +
  ylab('Average Cases') +
  labs(color = "Initial # Doctors") +
  theme_base() +
  guides(colour = guide_legend(override.aes = list(size=7)))



full_stats_DF = as.data.frame = full_stats
write.table(full_stats_DF)









