prepare_historical_data_per_spot = function(dirs){

  # input files
  input_dir = dirs$raw_data
  raw_data_files = dir(input_dir, ".*\\.Rds", full.names=T)

  # output
  output_dir = here(dirs$preprocessed_data, "historical_per_spot")
  if(!dir.exists(output_dir)){
    dir.create(output_dir)
  }

  # files in output_dir
  output_files = dir(output_dir, ".*\\.csv", full.names=T)




}
