# frozen_string_literal: true
require 'ec2_ipv4_retriever'
include Ec2Ipv4Retriever

server find_ip_by_ec2_name(ec2_name: 'OE24-hyrax-arch') || ENV['ARCH_SERVER_IP'], user: 'deploy', roles: [:web, :app, :db, :ubuntu]
set :stage, :ARCH
set :honeybadger_env, "SelfDeposit-Arch"
