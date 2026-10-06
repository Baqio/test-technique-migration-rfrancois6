class MigrationReport
  Issue = Struct.new(:level, :source, :locator, :message, :details, keyword_init: true)

  STATUS_LABELS = {
    "created"  => "créés",
    "updated"  => "mis à jour",
    "rejected" => "non repris"
  }.freeze

  attr_reader :issues, :counters

  def initialize
    @issues   = []
    @counters = Hash.new(0)
  end

  def count(key, by = 1)
    @counters[key.to_sym] += by
  end

  def warn(source:, locator:, message:, **details)
    add(:warning, source, locator, message, details)
  end

  def error(source:, locator:, message:, **details)
    add(:error, source, locator, message, details)
  end

  def errors   = issues.select { |issue| issue.level == :error }
  def warnings = issues.select { |issue| issue.level == :warning }

  def to_s
    sections = [header, summary, section("LIGNES NON REPRISES", errors), section("À VÉRIFIER", warnings)]
    (sections.compact + [footer]).join("\n\n")
  end

private

  def header
    "REPRISE CAVEGEST — #{Date.today.strftime('%d/%m/%Y')}"
  end

  def summary
    lines = counters
            .select { |key, _| key.to_s.include?("|") }
            .map    { |key, value| "  #{key.to_s.split('|').first} : #{value} #{STATUS_LABELS.fetch(key.to_s.split('|').last, key.to_s.split('|').last)}" }

    missing = counters[:prices_missing]
    lines << "  #{missing} tarifs absents de la source, aucune ligne créée" if missing.positive?

    (["RÉSULTAT"] + lines).join("\n")
  end

  def section(title, list)
    return nil if list.empty?

    blocks = list.group_by(&:source).map do |file, file_issues|
      reasons = file_issues.group_by(&:message).map do |message, group|
        "    #{group.size} ligne(s) — #{message}\n      #{positions(group)}"
      end

      "  #{file}\n#{reasons.join("\n\n")}"
    end

    ([title] + blocks).join("\n\n")
  end

  def positions(group)
    shown = group.first(10).map(&:locator).join(", ")
    rest  = group.size - 10

    rest.positive? ? "lignes #{shown} et #{rest} autres" : "lignes #{shown}"
  end

  def footer
    "Les lignes non reprises sont à corriger dans le fichier source avant " \
    "une nouvelle reprise. Les points à vérifier sont importés : ils " \
    "demandent seulement une confirmation."
  end

  def add(level, source, locator, message, details)
    @issues << Issue.new(level: level, source: source, locator: locator,
                         message: message, details: details)
  end
end
