#' Define full parameter set for mpox SEIR model
#'
#' @param beta_h Beta for sexual contact
#' @param beta_s Beta for household contact
#' @param beta_z Beta for spontaneous zoonotic infection
#' @param exp_noise Rate parameter of exponential random noise added
#'   to modelled case numbers in fitting procedure
#' @param initial_infections Number of initial infections
#' @param region Region to use contact and demographic data for
#' @param overrides List of default parameters in
#'   \code{parameters_fixed} to override from
get_pars <- function(beta_h, beta_s, beta_z,
                     exp_noise = 1e6,
                     initial_infections = 1,
                     region = c("equateur", "sudkivu", "burundi",
                                "bujumbura", "bujumbura_mairie"),
                     overrides = list(
                       daily_doses_children_time = 0,
                       daily_doses_adults_time = 0
                     )) {

  # match region
  region <- match.arg(region)

  # collate
  c(
    # beta for households
    beta_h = beta_h,
    # beta for sexual contacts
    beta_s = beta_h,
    # beta for zoonotic imports
    beta_z = list(rep(beta_z, 20)),
    exp_noise = exp_noise,
    parameters_fixed(
      region = region,
      initial_infections = initial_infections,
      overrides = overrides
    )
  )

}
