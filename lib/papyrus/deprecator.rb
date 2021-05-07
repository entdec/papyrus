class Papyrus::Deprecator
  def deprecation_warning(deprecated_method_name, message, _caller_backtrace = nil)
    message = "#{deprecated_method_name} is deprecated and will be removed from Papyrus | #{message}"
    Kernel.warn message
  end
end
