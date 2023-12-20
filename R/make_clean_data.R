#' Make clean data for github
#'
#' @param dirs all the directories
#'
#' @return
#' @export
#'
#' @examples
make_clean_data = function(dirs){

  # make daily data per spot  --------------------------------------------------
  # should include wave height, temperature, rating,...
  # this is one csv with all 8k spots per day...
  # keep getting more csvs

  daily_data_dir = here(dirs$preprocessed_data, "daily_data")
  # prepare_daily_data(dirs$raw_data, daily_data_dir)



  # make monthly aggregate per spot --------------------------------------------
  # should include wave height, temperature, rating,...
  # this is as many csvs as there are months in the data preprocessed
  # Each csv contains 8k spots
  monthly_data_dir = here(dirs$preprocessed_data, "monthly_data")
  # prepare_monthly_data(daily_data_dir = daily_data_dir,
  #                      monthly_data_dir = monthly_data_dir)



  # make historical data per spot  ---------------------------------------------
  # should include wave height, temperature, rating,...
  # this is one csv per spot with as many days in the data as possible
  # same number of csvs, where each gets larger over time


  # first summarise each timestamp data (not for github)
  dir_data_timestamp = here(dirname(dirs$raw_data), "per_spot")
  rondas::prepare_per_timestamp_per_spot(dir_data_raw = dirs$raw_data, dir_data_timestamp=dir_data_timestamp)

  # preprare_historical_daily_data_per_spot(dirs)





  # commit to github --------------------------------------------------------


}
