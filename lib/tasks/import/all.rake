namespace :import do
  desc "Lance la reprise CaveGest complète et affiche le rapport"
  task :all do
    report = MigrationReport.new

    Customer::Import::Cavegest.new(
      File.join(DATA_DIR, "export_clients_cavegest.xlsx"), report: report
    ).call

    ProductPrice::Import::Cavegest.new(
      File.join(DATA_DIR, "export_tarifs_cavegest.csv"), report: report
    ).call

    puts report
  end
end