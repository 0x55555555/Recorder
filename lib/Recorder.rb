require 'optparse'

Version = "1.0.0"

class RecordOptionParser < OptionParser
  attr_accessor :arguments
  attr_reader :run

  def initialize(subcmd=nil)
    super()

    if subcmd
      banner = "Usage: record #{subcmd} [options]"
    else
      banner = "Usage: record [options]"
    end

    on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end

    if block_given?
      yield self
    end
  end

  def on_run(&meth)
    @run = meth
  end
end

class RecordSubCommandOptionParser < RecordOptionParser
  attr_reader :command

  def initialize(subcmd)
    super(subcmd)
    @command = subcmd
  end
end

class Record
end

class Recorder
  def initialize(args)
    arguments = args.dup

    @verbose = false
    @records = []

    global = RecordOptionParser.new do |opts|
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @verbose = v
      end

    end

    begin
      global.order!(arguments)
    rescue OptionParser::InvalidOption
      puts "Error parsing options: #{$!}"
      puts global
      exit
    end

    subcommands = []
    subcommands << RecordSubCommandOptionParser.new(:add) do |opts|
      opts.on_run do
        puts "run add #{Time.new} #{arguments}"
        @records << Record.new
      end
    end

    command_name = arguments.shift
    command_search = subcommands.map{ |x| [x.command.to_s, x] }.to_h
    @command = command_search[command_name]

    if @command
      begin
        @command.parse!(arguments)
      rescue OptionParser::InvalidOption
        puts "Error parsing options: #{$!}"
        puts @command
        exit
      end

      @command.arguments = arguments
    else
      puts "Unknown command '#{command_name}'"
      puts global
      exit
    end
  end

  def run()
    @command.run.call
  end
end
