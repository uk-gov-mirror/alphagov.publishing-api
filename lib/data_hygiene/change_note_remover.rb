module DataHygiene
  class ChangeNoteNotFound < StandardError; end

  class ChangeNoteRemover
    def initialize(content_id, locale, change_note_search, dry_run:)
      @content_id = content_id
      @locale = locale
      @change_note_search = change_note_search
      @dry_run = dry_run
    end

    def call
      raise ChangeNoteNotFound.new unless change_note
      return change_note if dry_run

      destroy_change_note
      remove_change_history
      represent_downstream

      change_note
    end

    def self.call(*args)
      new(*args).call
    end

    private_class_method :new

  private

    attr_reader :content_id, :locale, :change_note_search, :dry_run

    def document
      @document ||= Document.find_by(content_id: content_id, locale: locale)
    end

    def find_change_note
      change_notes = document.editions.map(&:change_note).compact
      fuzzy_match = FuzzyMatch.new(change_notes, read: :note)
      fuzzy_match.find(change_note_search, must_match_at_least_one_word: true)
    end

    def change_note
      @change_note ||= find_change_note
    end

    def destroy_change_note
      change_note.destroy
    end

    def remove_change_history
      edition = document.live
      edition_details = edition.details
      edition_details.delete(:change_history)
      edition.update!(details: edition_details)
    end

    def represent_downstream
      Commands::V2::RepresentDownstream.new.call([content_id])
    end
  end
end
