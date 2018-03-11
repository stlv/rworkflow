# frozen_string_literal: true

require 'droplet_kit'
require 'optparse'
require 'ostruct'

API_TOKEN = ENV.fetch('API_TOKEN')

DROPLET_NAME = ENV.fetch('DROPLET_NAME', 'rworkflow')
DROPLET_SIZE = ENV.fetch('DROPLET_SIZE', 's-1vcpu-1gb')
DROPLET_REGION = ENV.fetch('DROPLET_REGION', 'ams3')
DROPLET_IMAGE = ENV.fetch('DROPLET_IMAGE', 'ubuntu-16-04-x64')

opt = OpenStruct.new

OptionParser.new do |parser|
  parser.banner = 'Usage: rworkflow [options]'

  parser.on('-t', '--token TOKEN', 'The API token.') do |o|
    opt.api_token = o || API_TOKEN
  end

  parser.on('-dn', '--droplet-name NAME', 'The name of the droplet to create.') do |o|
    opt.droplet_name = o || DROPLET_NAME
  end

  parser.on('-ds', '--droplet-size SIZE', 'The size of the droplet to create.') do |o|
    opt.droplet_size = o || DROPLET_SIZE
  end

  parser.on('-dr', '--droplet-region REGION', 'The region of the droplet to create.') do |o|
    opt.droplet_region = o || DROPLET_REGION
  end

  parser.on('-di', '--droplet-image IMAGE', 'The image of the droplet to create.') do |o|
    opt.droplet_image = o || DROPLET_IMAGE
  end

  parser.on('-s', '--start', 'Start work') do
    opt.start = true
  end

  parser.on('-f', '--finish', 'Finish work') do
    opt.finish = true unless opt.start
  end

  parser.on('-h', '--help', 'Show this help message.') do
    puts parser
  end
end.parse!

client = DropletKit::Client.new(access_token: opt.api_token)

if opt.start
  droplet = DropletKit::Droplet.new(
    name: opt.droplet_name,
    region: opt.droplet_region,
    image: opt.droplet_image,
    size: opt.droplet_size
  )
end

class Rworkflow
  attr_reader :client, :droplet

  def initialize(client: nil, droplet: nil)
    @client = client
    @droplet = droplet
  end

  def start
    create_droplet
    resolv_domain
    true
  end

  def finish
    client.droplets.delete(name: opt.droplet_name)
  end

  private

  def create_droplet
    client.droplets.create(droplet)
  end

  def resolv_domain
    nil
  end
end

rworkflow = Rworkflow.new(client: client, droplet: droplet)

rworkflow.start if opt.start
rworkflow.finish if opt.finish
