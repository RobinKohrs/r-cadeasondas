#' Make clean data for github
#'
#' @param dirs all the directories
#'
#' @return
#' @export
#'
#' @examples
make_clean_data = function(dirs){

  # make daily global data  --------------------------------------------------
  dir_daily_data_global = here(dirs$preprocessed_data, "daily_data_global")
  dir_raw_download = dirs$raw_data
  rondas::prepare_daily_data(dir_raw_download = dir_raw_download, dir_daily_data = dir_daily_data_global)

  # make monthly global data --------------------------------------------
  dir_monthly_data = here(dirs$preprocessed_data, "monthly_data_global")
  rondas::prepare_monthly_data(dir_daily_data = dir_daily_data_global,
                               dir_monthly_data = dir_monthly_data)



  # make historical data per spot  ---------------------------------------------
  dir_daily_data_spot = here(dirs$preprocessed_data, "daily_data_spot")
  # make_historical_data_per_spot(dir_daily_data_global = dir_daily_data_global,
  #                               dir_daily_data_spot = dir_daily_data_spot)


}
