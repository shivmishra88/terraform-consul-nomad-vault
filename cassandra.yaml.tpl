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
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: "10.0.1.17,10.0.1.18,10.0.1.19"
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
client_encryption_options:
    enabled: false
    optional: false
    keystore: resources/dse/conf/.keystore
    keystore_password: cassandra
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
    max_concurrent_sessions: 60
    max_session_pages: 4
    max_page_size_mb: 8
    max_local_query_time_ms: 5000
    client_timeout_sec: 600
    cancel_timeout_sec: 5
    paused_check_interval_ms: 1
nodesync:
    rate_in_kb: 1024
