# Ebola Networks

This project uses a smallworld network to simulate the spread of ebolavirus through a small community. 

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
- Model is here run to 100 timesteps [recommended to run to completion, can do this with a while loop]
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

