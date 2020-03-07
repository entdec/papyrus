# frozen_string_literal: true

require 'tilt'
require 'prawn'
require 'prawn-svg'
require 'prawn/table'
require 'prawn/measurement_extensions'

require 'barby'
require 'barby/barcode/bookland'
require 'barby/barcode/codabar'
require 'barby/barcode/code_25'
require 'barby/barcode/code_25_iata'
require 'barby/barcode/code_25_interleaved'
require 'barby/barcode/code_39'
require 'barby/barcode/code_93'
require 'barby/barcode/code_128'
require 'barby/barcode/data_matrix'
require 'barby/barcode/ean_8'
require 'barby/barcode/ean_13'
require 'barby/barcode/gs1_128'
require 'barby/barcode/qr_code'
require 'barby/barcode/upc_supplemental'
require 'barby/outputter/prawn_outputter'

require 'papyrus/engine'
require 'papyrus/configuration'
require 'papyrus/context'

module Papyrus
  # Your code goes here...
end
