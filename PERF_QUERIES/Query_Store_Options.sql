--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE CLEAR;

SELECT actual_state_desc, desired_state_desc, current_storage_size_mb,
    max_storage_size_mb, readonly_reason, interval_length_minutes,
    stale_query_threshold_days, size_based_cleanup_mode_desc,
    query_capture_mode_desc
FROM sys.database_query_store_options;


--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_ONLY);

--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (QUERY_CAPTURE_MODE = AUTO);

 
--ALTER DATABASE [Honeywell.MES.Operations.DataModel.OperationsDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
   