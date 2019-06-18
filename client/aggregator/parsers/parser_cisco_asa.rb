require 'fluent/parser'

module Fluent
  class TextParser
    class FirewallParser < Parser
      # Register this parser as "firewall"
      Fluent::Plugin.register_parser("cisco_asa", self)

      TIME = '\w+\s+\d{1,2}\s+\d{2}:\d{2}:\d{2}'
      IPV4 = '\d{1,3}(?:\.\d{1,3}){3}'
      IPV6 = '[0-9a-fA-F]{1,4}(?:::?[0-9a-fA-F]{1,4}){1,7}'
      IP = "(?:#{IPV4}|#{IPV6})"
      IPORHOST = '[\w:.-]+'
      ACTION = '(?:denied|permitted)'
      CONNECT = '(?:Built|Teardown)'
      DIRECTION = '(?:inbound|outbound)'

      # For NAT Connection
      RGX1 = /^(?<time>#{TIME}) (?<ip_fw>[^ ]+) [^ ]+ (?<action>#{CONNECT}) (?<nat>dynamic) (?<proto>(?:TCP|UDP|ICMP)) translation from (?<if_src>\w+):(?<ip_src>#{IPORHOST})\/(?<port_src>\d+) to (?<if_dst>\w+):(?<ip_dst>#{IPORHOST})\/(?<port_dst>\d+)/

      # For ICMP Connection Built
      RGX2 = /^(?<time>#{TIME}) (?<ip_fw>[^ ]+) [^ ]+ (?<action>#{CONNECT}) (?<direction>#{DIRECTION}) (?<proto>ICMP) connection for faddr (?<ip_src>#{IPORHOST})\/(?<port_src>\d+) gaddr (?<ip_dst>#{IPORHOST})\/(?<port_dst>\d+) laddr (?<ip_local>#{IPORHOST})\/(?<port_local>\d+)/

      # For TCP/UDP Connection Built
      RGX3 = /^(?<time>#{TIME}) (?<ip_fw>[^ ]+) [^ ]+ (?<action>#{CONNECT}) (?<direction>#{DIRECTION}) (?<proto>(?:TCP|UDP)) .* (?<if_src>\w+):(?<ip_src>#{IPORHOST})\/(?<port_src>\d+) \(.*\) to (?<if_dst>\w+):(?<ip_dst>#{IPORHOST})\/(?<port_dst>\d+) .*/

      ### ToDo Update the format ###
      RGX4 = /^(?<time>#{TIME}) (?<ip_fw>#{IP}) [^ ]* (?<action>Deny) inbound (?<proto>UDP) from (?<ip_src>#{IPORHOST})\/(?<port_src>\d+) to (?<ip_dst>#{IPORHOST})\/(?<port_dst>\d+)/
      RGX5 = /^(?<time>#{TIME}) (?<ip_fw>#{IP}) [^ ]* (?<action>Deny) (?<proto>(?:TCP|UDP|ICMP|IPv6-ICMP)) reverse path check from (?<ip_src>#{IPORHOST}) to (?<ip_dst>#{IPORHOST})/
      RGX6 = /^(?<time>#{TIME}) (?<ip_fw>#{IP}) [^ ]* (?<action>Deny) inbound (?<proto>icmp) src \w+:(?<ip_src>#{IPORHOST}) dst \w+:(?<ip_dst>#{IPORHOST}) \(type (?<icmp_type>\d), code (?<icmp_code>\d)\)/
      RGX7 = /^(?<time>#{TIME}) (?<ip_fw>#{IP}) [^ ]* (?<action>Deny) inbound protocol (?<proto>\d+) src \w+:(?<ip_src>#{IPORHOST}) dst \w+:(?<ip_dst>#{IPORHOST})/
      RGX8 = /^(?<time>#{TIME}) (?<ip_fw>#{IP}) [^ ]* (?<proto>TCP) access (?<action>denied) by ACL from (?<ip_src>#{IPORHOST})\/(?<port_src>\d+) to \w+:(?<ip_dst>#{IPORHOST})\/(?<port_dst>\d+)/
      #RGX9 = /^(?<time>#{TIME}) (?<ip_fw>#{IP}) [^ ]* \[\s*(?<proto>\w+)\s*(?<port_dst>\d+)\] (?<action>drop) rate-1 exceeded. Current burst rate is \d+ per second, max configured rate is \d+; Current average rate is \d+ per second, max configured rate is \d+; Cumulative total count is \d+/
      REGEX = Regexp.union(RGX1, RGX2, RGX3, RGX4, RGX5, RGX6, RGX7, RGX8)
      TIME_FORMAT = "%b %e %H:%M:%S"
      # This method is called after config_params have read configuration parameters
      def configure(conf)
        super
        # TimeParser class is already given. It takes a single argument as the time format
        # to parse the time string with.
        @time_parser = TimeParser.new(TIME_FORMAT)
      end

      # This is the main method. The input "text" is the unit of data to be parsed.
      # If this is the in_tail plugin, it would be a line. If this is for in_syslog,
      # it is a single syslog message.
      def parse(text)
        record = {}
        time = nil
        unless m = REGEX.match(text)
          yield nil, nil
        else
          names = m.names

          time = @time_parser.parse(m['time'])
          record["ip_fw"] = m['ip_fw']
          record["action"] = m['action']
          record["direction"] = m['direction']
          record["proto"] = m['proto'].downcase
          record["nat"] = m['nat']
          record["if_src"] = m['if_src']
          record["if_dst"] = m['if_dst']
          record["ip_src"] = m['ip_src']
          record["ip_dst"] = m['ip_dst']
          record["ip_local"] = m['ip_local']
          record["port_src"] = m['port_src'].to_i if m['port_src']
          record["port_dst"] = m['port_dst'].to_i if m['port_dst']
          record["port_local"] = m['port_local'].to_i if m['port_local']
          record["icmp_type"] = m['icmp_type'].to_i if m['icmp_type']
          record["icmp_code"] = m['icmp_code'].to_i if m['icmp_code']

          yield time, record
        end
      end
    end
  end
end
