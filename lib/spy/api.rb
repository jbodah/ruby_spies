require 'spy/core'
require 'spy/blueprint'
require 'set'

module Spy
  # The core module that users will interface. `Spy::API` is implemented
  # in a module via `::extend`:
  #
  #   MySpy.exted Spy::API
  #   spy = MySpy.on(Object, :name)
  #
  # By default `Spy` implements `Spy::API`
  #
  # `Spy::API` is primarily responsible for maps user arguments into
  # a format that `Spy::Core` can understand
  #
  # See `Spy::Instance` for the API for interacting with individual spies
  module API
    # Spies on calls to a method made on a target object
    #
    # @param [Object] target - the object you want to spy on
    # @param [Symbol] msg - the name of the method to spy on
    # @returns [Spy::Instance]
    def on(target, msg)
      if target.methods.include?(msg)
        core.add_spy(Blueprint.new(target, msg, :method))
      elsif target.respond_to?(msg)
        core.add_spy(Blueprint.new(target, msg, :dynamic_delegation))
      else
        raise ArgumentError
      end
    end

    # Spies on calls to a method made on any instance of some class or module
    #
    # @param target - class or module to spy on
    # @param msg - name of the method to spy on
    # @returns [Spy::Instance]
    def on_any_instance(target, msg)
      raise ArgumentError unless target.respond_to?(:instance_method)
      core.add_spy(Blueprint.new(target, msg, :instance_method))
    end

    # Spies on all of the calls made to the given object
    #
    # @param object - the thing to spy on
    # @returns [Spy::Multi]
    def on_object(object)
      core.add_multi_spy(Blueprint.new(object, :all, :methods))
    end

    # Spies on all of the calls made to the given class or module
    #
    # @param klass - the thing to spy on
    # @returns [Spy::Multi]
    def on_class(klass)
      core.add_multi_spy(Blueprint.new(klass, :all, :instance_methods))
    end

    # Traverse a namespace and build up a Spy::Multi representing the entire
    # namespace
    def infect(klass)
      blueprints = []
      seen = Set.new
      queue = [klass]
      until queue.empty?
        klass = queue.shift
        blueprints += [
          Blueprint.new(klass, :all, :instance_methods),
          Blueprint.new(klass, :all, :methods)
        ]
        mods = klass.constants.map { |const| klass.const_get(const) }.select { |obj| obj.is_a?(Module) }
        mods.reject! { |mod| seen.include?(mod) }
        seen += mods
        queue += mods
      end
      core.add_multi_spy(blueprints)
    end

    # Stops spying on the method and restores its original functionality
    #
    # @example stop spying on every spied message
    #
    #   Spy.restore(:all)
    #
    # @example stop spying on the given receiver and message
    #
    #   Spy.restore(receiver, msg)
    #
    # @example stop spying on the given object, message, and type (e.g. :method, :instance_method, :dynamic_delegation)
    #
    #   Spy.restore(object, msg, type)
    #
    # @param args - supports multiple signatures
    def restore(*args)
      case args.length
      when 1
        core.remove_all_spies if args.first == :all
      when 2
        target, msg = *args
        core.remove_spy(Blueprint.new(target, msg, :method))
      when 3
        target, msg, type = *args
        core.remove_spy(Blueprint.new(target, msg, type))
      else
        raise ArgumentError
      end
    end

    private

    def core
      @core ||= Core.new
    end
  end
end
