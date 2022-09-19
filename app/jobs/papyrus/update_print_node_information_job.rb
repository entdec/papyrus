module Papyrus
  class UpdatePrintNodeInformationJob < ApplicationJob
    def perform
      return unless Papyrus.print_client

      Papyrus.print_client.computers.each do |c|
        computer = Papyrus::Computer.find_or_initialize_by(client_id: c.id)
        computer.name = c.name
        computer.hostname = c.hostname
        computer.state = c.state
        computer.save!
      end

      Papyrus.print_client.printers.each do |p|
        printer = Papyrus::Printer.find_or_initialize_by(client_id: p.id)
        printer.name = p.description
        printer.state = p.state
        printer.computer = Papyrus::Computer.find_by(client_id: p.computer.id)

        printer.save!
      end

      computers = Papyrus::Computer.where.not(client_id: Papyrus.print_client.computers.map(&:id))
      printers = Papyrus::Printer.where.not(client_id: Papyrus.print_client.printers.map(&:id))

      Papyrus::PreferredPrinter.where(printer_id: printers.map(&:id))
                               .or(Papyrus::PreferredPrinter.where(computer_id: computers.map(&:id))).destroy_all

      printers.destroy_all
      computers.destroy_all
    end
  end
end
