module Papyrus
  class UpdatePrintNodeInformationJob < ApplicationJob
    def perform
      return unless Papyrus.print_client

      computers = []
      printers = []
      Papyrus.print_client.computers.each do |c|
        computer = Papyrus::Computer.find_or_initialize_by(client_id: c.id)
        computer.name = c.name
        computer.hostname = c.hostname
        computer.state = c.state
        computer.save!

        computers << c.id

        Papyrus.print_client.printers(c.id, '').each do |p|
          printer = Papyrus::Printer.find_or_initialize_by(client_id: p.id)
          printer.name = p.description
          printer.state = p.state
          printer.computer = computer

          printer.save!

          printers << p.id
        end
      end

      Papyrus::PreferredPrinter.where(printer_id: printers.map(&:id))
                               .or(Papyrus::PreferredPrinter.where(computer_id: computers.map(&:id))).destroy_all

      printers.destroy_all
      computers.destroy_all
    end
  end
end
