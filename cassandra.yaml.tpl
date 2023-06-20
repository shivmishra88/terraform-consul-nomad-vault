


cluster_name: 'Test Cluster'




hinted_handoff_enabled: true


max_hint_window_in_ms: 10800000 # 3 hours

hinted_handoff_throttle_in_kb: 1024

max_hints_delivery_threads: 2

hints_directory: /var/lib/cassandra/hints

hints_flush_period_in_ms: 10000

max_hints_file_size_in_mb: 128


batchlog_replay_throttle_in_kb: 1024


authenticator: com.datastax.bdp.cassandra.auth.DseAuthenticator

authorizer: com.datastax.bdp.cassandra.auth.DseAuthorizer

role_manager: com.datastax.bdp.cassandra.auth.DseRoleManager

system_keyspaces_filtering: false

roles_validity_in_ms: 120000


permissions_validity_in_ms: 120000


partitioner: org.apache.cassandra.dht.Murmur3Partitioner

data_file_directories:
     - /var/lib/cassandra/data

metadata_directory: /var/lib/cassandra/metadata

commitlog_directory: /var/lib/cassandra/commitlog

cdc_enabled: false

cdc_raw_directory: /var/lib/cassandra/cdc_raw

disk_failure_policy: stop

commit_failure_policy: stop

prepared_statements_cache_size_mb:


row_cache_size_in_mb: 0

row_cache_save_period: 0


counter_cache_size_in_mb:

counter_cache_save_period: 7200


saved_caches_directory: /var/lib/cassandra/saved_caches

commitlog_sync: periodic
commitlog_sync_period_in_ms: 10000

commitlog_segment_size_in_mb: 32


seed_provider:
    # Addresses of hosts that are deemed contact points.
    # Database nodes use this list of hosts to find each other and learn
    # the topology of the ring. You _must_ change this if you are running
    # multiple nodes!
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "10.0.1.17,10.0.1.18"









memtable_allocation_type: offheap_objects





trickle_fsync: true
trickle_fsync_interval_in_kb: 10240

storage_port: 7000

ssl_storage_port: 7001

listen_address: $private_ip






start_native_transport: true
native_transport_port: 9042



native_transport_allow_older_protocols: true

native_transport_address: $private_ip




native_transport_keepalive: true



incremental_backups: false

snapshot_before_compaction: false

snapshot_before_dropping_column: false

auto_snapshot: true


column_index_size_in_kb: 16

column_index_cache_size_in_kb: 2



concurrent_materialized_view_builders: 2



compaction_throughput_mb_per_sec: 16

sstable_preemptive_open_interval_in_mb: 50




zerocopy_max_unused_metadata_in_mb: 200

zerocopy_max_sstables: 256





read_request_timeout_in_ms: 5000
range_request_timeout_in_ms: 10000
aggregated_request_timeout_in_ms: 120000
write_request_timeout_in_ms: 2000
counter_write_request_timeout_in_ms: 5000
cas_contention_timeout_in_ms: 1000
truncate_request_timeout_in_ms: 60000
request_timeout_in_ms: 10000

slow_query_log_timeout_in_ms: 500

cross_node_timeout: false






endpoint_snitch: com.datastax.bdp.snitch.DseSimpleSnitch

dynamic_snitch_update_interval_in_ms: 100
dynamic_snitch_reset_interval_in_ms: 600000
dynamic_snitch_badness_threshold: 0.1

server_encryption_options:
    internode_encryption: none
    keystore: resources/dse/conf/.keystore
    keystore_password: cassandra
    truststore: resources/dse/conf/.truststore
    truststore_password: cassandra
    # More advanced defaults below:
    # protocol: TLS
    # algorithm: SunX509
    #
    # Set keystore_type for keystore, valid types can be JKS, JCEKS, PKCS12 or PKCS11
    # for file based keystores prefer PKCS12
    # keystore_type: JKS
    #
    # Set truststore_type for truststore, valid types can be JKS, JCEKS or PKCS12
    # for file based truststores prefer PKCS12
    # truststore_type: JKS
    #
    # cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
    # require_client_auth: false
    # require_endpoint_verification: false

client_encryption_options:
    enabled: false
    # If enabled and optional is set to true, encrypted and unencrypted connections over native transport are handled.
    optional: false
    keystore: resources/dse/conf/.keystore
    keystore_password: cassandra

    # Set require_client_auth to true to require two-way host certificate validation
    # require_client_auth: false
    #
    # Set truststore and truststore_password if require_client_auth is true
    # truststore: resources/dse/conf/.truststore
    # truststore_password: cassandra
    #
    # More advanced defaults below:
    # default protocol is TLS
    # protocol: TLS
    # algorithm: SunX509
    #
    # Set keystore_type for keystore, valid types can be JKS, JCEKS, PKCS12 or PKCS11
    # for file based keystores prefer PKCS12
    # keystore_type: JKS
    #
    # Set truststore_type for truststore, valid types can be JKS, JCEKS or PKCS12
    # for file based truststores prefer PKCS12
    # truststore_type: JKS
    #
    # cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]

internode_compression: dc

inter_dc_tcp_nodelay: false

tracetype_query_ttl: 86400
tracetype_repair_ttl: 604800

windows_timer_interval: 1

enable_user_defined_functions: false

enable_scripted_user_defined_functions: false

enable_user_defined_functions_threads: true

user_defined_function_warn_micros: 500

user_defined_function_fail_micros: 10000

user_defined_function_warn_heap_mb: 200

user_defined_function_fail_heap_mb: 500

user_function_timeout_policy: die


transparent_data_encryption_options:
    enabled: false
    chunk_length_kb: 64
    cipher: AES/CBC/PKCS5Padding
    key_alias: testing:1
    # CBC IV length for AES must be 16 bytes, the default size
    # iv_length: 16
    key_provider:
      - class_name: org.apache.cassandra.security.JKSKeyProvider
        parameters:
          - keystore: conf/.keystore
            keystore_password: cassandra
            store_type: JCEKS
            key_password: cassandra







back_pressure_enabled: false
back_pressure_strategy:
    - class_name: org.apache.cassandra.net.RateBasedBackPressure
      parameters:
        - high_ratio: 0.90
          factor: 5
          flow: FAST






continuous_paging:
    # The maximum number of concurrent sessions, any additional session will be rejected with an unavailable error.
    max_concurrent_sessions: 60
    # The maximum number of pages that can be buffered for each session
    max_session_pages: 4
    # The maximum size of a page, in MB. If an individual CQL row is larger than this value, the page can be larger than
    # this value.
    max_page_size_mb: 8
    # The maximum time in milliseconds for which a local continuous query will run, assuming the client continues
    # reading or requesting pages. When this threshold is exceeded, the session is swapped out and rescheduled.
    # Swapping and rescheduling resources ensures the release of resources including those that prevent the memtables
    # from flushing. Adjust when high write workloads exist on tables that have
    # continuous paging requests.
    max_local_query_time_ms: 5000
    # The maximum time the server will wait for a client to request more pages, in seconds, assuming the
    # server queue is full or the client has not required any more pages via a backpressure update request.
    # Increase this value for extremely large page sizes (max_page_size_mb)
    # or for extremely slow networks.
    client_timeout_sec: 600
    # How long the server waits for a cancel request to complete, in seconds.
    cancel_timeout_sec: 5
    # How long the server will wait, in milliseconds, before checking if a continuous paging session can be resumed when
    # the session is paused because of backpressure.
    paused_check_interval_ms: 1


nodesync:
    # The (maximum) rate (in kilobytes per second) for data validation.
    rate_in_kb: 1024


  # When executing a scan, within or across a partition, we need to keep the
  # tombstones seen in memory so we can return them to the coordinator, which
  # will use them to make sure other replicas also know about the deleted rows.
  # With workloads that generate a lot of tombstones, this can cause performance
  # problems and even exhaust the server heap.
  # (http://www.datastax.com/dev/blog/cassandra-anti-patterns-queues-and-queue-like-datasets)
  # Adjust the thresholds here if you understand the dangers and want to
  # scan more tombstones anyway.  These thresholds may also be adjusted at runtime
  # using the StorageService mbean.
  #
  # Default tombstone_warn_threshold is 1000, may differ if emulate_dbaas_defaults is enabled
  # Default tombstone_failure_threshold is 100000, may differ if emulate_dbaas_defaults is enabled
  # tombstone_warn_threshold: 1000
  # tombstone_failure_threshold: 100000

  # Log a warning when compacting partitions larger than this value.
  # Default value is 100mb, may differ if emulate_dbaas_defaults is enabled
  # partition_size_warn_threshold_in_mb: 100

  # Log WARN on any multiple-partition batch size that exceeds this value. 64kb per batch by default.
  # Use caution when increasing the size of this threshold as it can lead to node instability.
  # Default value is 64kb, may differ if emulate_dbaas_defaults is enabled
  # batch_size_warn_threshold_in_kb: 64

  # Fail any multiple-partition batch that exceeds this value. The calculated default is 640kb (10x warn threshold).
  # Default value is 640kb, may differ if emulate_dbaas_defaults is enabled
  # batch_size_fail_threshold_in_kb: 640

  # Log WARN on any batches not of type LOGGED than span across more partitions than this limit.
  # Default value is 10, may differ if emulate_dbaas_defaults is enabled
  # unlogged_batch_across_partitions_warn_threshold: 10

  # Failure threshold to prevent writing large column value into Cassandra.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # column_value_size_failure_threshold_in_kb: -1

  # Failure threshold to prevent creating more columns per table than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # columns_per_table_failure_threshold: -1

  # Failure threshold to prevent creating more fields in user-defined-type than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # fields_per_udt_failure_threshold: -1

  # Warning threshold to warn when encountering larger size of collection data than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # collection_size_warn_threshold_in_kb: -1

  # Warning threshold to warn when encountering more elements in collection than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # items_per_collection_warn_threshold: -1

  # Whether read-before-write operation is allowed, eg. setting list element by index, removing list element
  # by index. Note: LWT is always allowed.
  # Default true to allow read before write operation, may differ if emulate_dbaas_defaults is enabled
  # read_before_write_list_operations_enabled: true

  # Failure threshold to prevent creating more secondary index per table than threshold (does not apply to CUSTOM INDEX StorageAttachedIndex)
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # secondary_index_per_table_failure_threshold: -1

  # Failure threshold for number of StorageAttachedIndex per table (only applies to CUSTOM INDEX StorageAttachedIndex)
  # Default is 10 (same when emulate_dbaas_defaults is enabled)
  # sai_indexes_per_table_failure_threshold: 10
  #
  # Failure threshold for total number of StorageAttachedIndex across all keyspaces (only applies to CUSTOM INDEX StorageAttachedIndex)
  # Default is 10 (same when emulate_dbaas_defaults is enabled)
  # sai_indexes_total_failure_threshold: 100

  # Failure threshold to prevent creating more materialized views per table than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # materialized_view_per_table_failure_threshold: -1

  # Warn threshold to warn creating more tables than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # tables_warn_threshold: -1

  # Failure threshold to prevent creating more tables than threshold.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # tables_failure_threshold: -1

  # Preventing creating tables with provided configurations.
  # Default all properties are allowed, may differ if emulate_dbaas_defaults is enabled
  # table_properties_disallowed:

  # Whether to allow user-provided timestamp in write request
  # Default true to allow user-provided timestamp, may differ if emulate_dbaas_defaults is enabled
  # user_timestamps_enabled: true

  # Preventing query with provided consistency levels
  # Default all consistency levels are allowed.
  # write_consistency_levels_disallowed:

  # Failure threshold to prevent providing larger paging by bytes than threshold, also served as a hard paging limit
  # when paging by rows is used.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # page_size_failure_threshold_in_kb: -1

  # Failure threshold to prevent IN query creating size of cartesian product exceeding threshold, eg.
  # "a in (1,2,...10) and b in (1,2...10)" results in cartesian product of 100.
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # in_select_cartesian_product_failure_threshold: -1

  # Failure threshold to prevent IN query containing more partition keys than threshold
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # partition_keys_in_select_failure_threshold: -1

  # Warning threshold to warn when local disk usage exceeding threshold. Valid values: (1, 100]
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # disk_usage_percentage_warn_threshold: -1

  # Failure threshold to reject write requests if replica disk usage exceeding threshold. Valid values: (1, 100]
  # Default -1 to disable, may differ if emulate_dbaas_defaults is enabled
  # disk_usage_percentage_failure_threshold: -1

  # Allows configuring max disk size of data directories when calculating thresholds for disk_usage_percentage_warn_threshold
  # and disk_usage_percentage_failure_threshold. Valid values: (1, max available disk size of all data directories]
  # Default -1 to disable and use the physically available disk size of data directories during calculations.
  # may differ if emulate_dbaas_defaults is enabled
  # disk_usage_max_disk_size_in_gb: -1

  # enabled: false
  # Directory used by the backup service to stage files during backup or restore operations.
  # If not set, the default directory is $CASSANDRA_HOME/data/backups_staging.
  # staging_directory: /var/lib/cassandra/backups_staging
  # Maximum number of times that a backup task will be retried after failures.
  # backups_max_retry_attemps: 5





