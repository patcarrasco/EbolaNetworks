#### File list--for each parameter tested, there is one:
- Raw data file containing network information at each timestep
- Raw data file containing health information for agents at each timestep
- Full model with graphs

# Model Information

### The default parameters for this model are as follows:
- Population = 1000
- Timesteps = 100
- CFR = 0.65
- Initial number of infected = 10
- Health workers in population = 10

### Assumptions for model:
- Population is ignorant of ebolavirus
- Deceased individalas are buried the same day of death
- Deceased are more infectious than infected individuals
- Healers / Doctors will always seek to help infected

### Tested parameters:
- Transmission from dead --> susceptible
- Transmission from infected --> susceptible
- Case Fatality Rate effect on transmission
- Amount of health workers effect on transmission

### Model Description
- Model is here run to 100 timesteps (It is recommended to run to completion, and this can be done with a while loop. However this may cause model to take > 5 hours to run each tested parameter)
- 100 iterations are done for each tested parameter

#### 1. Doctor Movements
- Doctor / Healthcare worker checks for connection to infected
- If doctor is attached to an infected, no movement occurs
- If doctor is NOT attached to an infected, doctor will find an infected person in the population to attach to
- Doctor will attempt to heal infected individaul

#### 2. Latent Individuals Checked
- Exposed individuals are identified, checked and updated in the exposed registry
- Individuals exposed for 8 days become symptomatic and enter infected class

#### 3. Infected Individuals Checked
- Infected individauls are identified, checked and updated in the infected registry
- At 3 days in, infected indivudals can start to feel better and enter recovered class
- Past 3 days in, infected individuals can start dying
- At 8 days in, infected individuals die

#### 4. New Infections
- If infected person connected to a susceptible person, infection can occur at previously set probability
- If dead person connected to a susceptibe person, infection can occur at previously set probability

#### 5. Burials
- Dead individauls are removed from the network











# Results

#### Example of one simulation of a community at time step 1
![image](https://user-images.githubusercontent.com/39533889/40403915-f0dbe588-5e22-11e8-9ea7-708de69096f0.png)
#### Example of case data obtained from 100 simulations of control parameters
![image](https://user-images.githubusercontent.com/39533889/40403927-fd6db8bc-5e22-11e8-9e5b-c65e897f8d18.png)\
The blue line is the average number of cases present at each time step
#### Example of death data obtained from 100 simulations of control parameters
![image](https://user-images.githubusercontent.com/39533889/40403931-ffd06e24-5e22-11e8-839e-d8ec9308718c.png)\
The blue line is the average number of deaths at each time step.  

## Testing a range of Case Fatality Rates
![image](https://user-images.githubusercontent.com/39533889/40403942-0bb6c77e-5e23-11e8-9ff7-3057ddf694e4.png)\
Normally distributed, W = 0.92105, p-value = 0.4385\
AOV: F = 3.904, p = 0.0956, No statistical  difference

![image](https://user-images.githubusercontent.com/39533889/40403944-0e972920-5e23-11e8-80e4-517f488dfdba.png)\
Normally distributed : W = 0.97896, p-value = 0.9576\
AOV: F = 0.125, p = 0.736, No statistical difference
##### This is result is interesting. One could expect a higher case fatality rate resulting in a higher amount of deaths. However, this lack of difference could be due to higher CFR rates being detrimental to viral success. A higher death rate could decrease the chances the virus has to infect another individual.

## Changing amount of treatment available in the community
![image](https://user-images.githubusercontent.com/39533889/40403948-1382bcf6-5e23-11e8-8be1-4916b890e3d3.png)\
Normally Distributed: W = 0.93463, p-value = 0.4949\
AOV:  F = 0.469, p = 0.513, No statistical difference

![image](https://user-images.githubusercontent.com/39533889/40403954-17ada822-5e23-11e8-9d16-b00a7a944c83.png)\
Normally distributed :W = 0.97536, p-value = 0.9356\
AOV: F = 0.358  p = 0.566, No statistical difference

## Testing a range of infection rates from corpses
![image](https://user-images.githubusercontent.com/39533889/40403959-1d71b0fa-5e23-11e8-9749-8b85da05792f.png)\
Shapiro-wilks: W = 0.93404, p-value = 0.4888\
AOV: F = 380.9, p < 0.001, means of case numbers statistically different

![image](https://user-images.githubusercontent.com/39533889/40403963-221bca1e-5e23-11e8-9217-cce369af9519.png)\
Shapiro-Wilks: W = 0.93291, p-value = 0.4771\
AOV: F = 349.1, p < 0.001, means of deaths statistically different

## Testing a range of infection rates from live hosts
![image](https://user-images.githubusercontent.com/39533889/40403967-261f2836-5e23-11e8-8085-95b588753a2b.png)\
Shapiro-wilks: W = 0.9631, p-value = 0.8206\
AOV: F = 102.8, p <.001, means of case numbers statistically different

![capture](https://user-images.githubusercontent.com/39533889/40403971-2c581348-5e23-11e8-8d79-62c6942c737a.PNG)\
Shapiro-Wilks: W = 0.95509, p-value = 0.7287\
AOV: F = 95.55, p < 0.001, means of deahts statistically different
