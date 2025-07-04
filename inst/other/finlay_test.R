# install mpoxseir with dependencies
if(!require(mpoxseir))
  devtools::install(here::here(), dependencies = TRUE)

# packages
pacman::p_load(here, dust2, tidyverse, reshape2, mpoxseir)

# compile model
gen <- odin2::odin(here("inst/odin/model-targeted-vax.R"))

# inspect parameter inputs
coef(sys)

# get full parameter set
pars <- get_pars(beta_h = 0.05, beta_s = 0.15, beta_z = 0)

# generate dust system for simulation054
sys <- dust_system_create(gen, pars = pars, n_particles = 20)
dust_system_set_state_initial(sys)

n_weeks <- 100
t <- seq(0, n_weeks*7)
y <- dust_unpack_state(sys, dust_system_simulate(sys, t))

# Convert to tibble and add run labels as a column
melt(y$observed_cases_inc) |>
  transmute(run = Var1, t = Var2, incidence = value) |>
  ## filter(t %% 7 == 0) |>
  filter(t < 50 & run == 1) |>
  ggplot(aes(t, incidence, group = run)) +
  geom_line(alpha = 0.25)

# this gives number in the Ea category (but is not new incidence)
data <- read.csv(here("inst/extdata/example_DZA.csv")) |>
  transmute(time = as.Date(date), deaths, cases) |>
  mutate(time = (floor(as.numeric(time - min(time) + 1)/7) + 1)*7) |>
  summarise(across(everything(), sum), .by = time) |>
  complete(time = seq_len(max(time)), fill = list(deaths = NA, cases = NA))

filter <- dust_filter_create(gen, time_start = 0, data = data, n_particles = 50)
dust_likelihood_run(filter, pars, save_trajectories = TRUE)

y <- dust_likelihood_last_trajectories(filter)
y <- dust_unpack_state(filter, y)
# Convert to tibble and add run labels as a column
melt(y$observed_cases_inc) |>
  transmute(run = Var1, t = Var2, incidence = value) |>
  ## filter(t %% 7 == 0) |>
  ggplot() +
  geom_line(aes(t, incidence, group = run), alpha = 0.1) +
  geom_point(data = data, aes(time, cases))
