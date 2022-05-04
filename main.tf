#Create sharded ClickHouse Cluster
#Link to terraform documentation - https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/mdb_clickhouse_cluster

resource "yandex_mdb_clickhouse_cluster" "foo" {
  name        = "sharded"
  environment = "PRODUCTION"
  version = "22.4"
  network_id  = var.default_network_id

  clickhouse {
    resources {
      resource_preset_id = "s2.micro" //resource_preset_id - types are in the official documentation
      disk_type_id       = "network-ssd" //disk_type_id - types are in the official documentation
      disk_size          = 16 //disk size
    }
  }

  zookeeper {
    resources {
      resource_preset_id = "s2.micro" //resource_preset_id - types are in the official documentation
      disk_type_id       = "network-ssd" //disk_type_id - types are in the official documentation
      disk_size          = 10 //disk size
    }
  }

  database {
    name = "db_name"
  }

  user {
    name     = "user"
    password = "password"
    permission {
      database_name = "db_name"
    }
    settings {
      max_memory_usage_for_user               = 1000000000 //Limits the maximum memory usage (in bytes) for processing of user's queries on a single server
      read_overflow_mode                      = "throw" //Sets behaviour on overflow while read. Possible values: throw - abort query execution, return an error; break - stop query execution, return partial result.
      output_format_json_quote_64bit_integers = true //If the value is true, integers appear in quotes when using JSON* Int64 and UInt64 formats (for compatibility with most JavaScript implementations); otherwise, integers are output without the quotes.
    }
    quota {
      interval_duration = 3600000 //Duration of interval for quota in milliseconds
      queries           = 10000 //The total number of queries
      errors            = 1000 //The number of queries that threw exception
    }
    quota {
      interval_duration = 79800000
      queries           = 50000
      errors            = 5000
    }
  }

  host {
    type       = "CLICKHOUSE" //The type of the host to be deployed. Can be either CLICKHOUSE or ZOOKEEPER
    zone       = "ru-central1-a"
    subnet_id  = var.default_subnet_id_zone_a
    shard_name = "shard1" //The name of the shard to which the host belongs
  }

  host {
    type       = "CLICKHOUSE"
    zone       = "ru-central1-b"
    subnet_id  = var.default_subnet_id_zone_b
    shard_name = "shard1"
  }

  host {
    type       = "CLICKHOUSE"
    zone       = "ru-central1-b"
    subnet_id  = var.default_subnet_id_zone_b
    shard_name = "shard2"
  }

  host {
    type       = "CLICKHOUSE"
    zone       = "ru-central1-c"
    subnet_id  = var.default_subnet_id_zone_c
    shard_name = "shard2"
  }

  shard_group { //A group of clickhouse shards
    name        = "single_shard_group"
    description = "Cluster configuration that contain only shard1"
    shard_names = [
      "shard1",
    ]
  }

  cloud_storage {
    enabled = false //Whether to use Yandex Object Storage for storing ClickHouse data. Can be either true or false
  }
}