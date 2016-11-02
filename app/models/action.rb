class Action < ActiveRecord::Base
  belongs_to :content_item
  belongs_to :link_set
  belongs_to :event

  validate :one_of_content_item_link_set

  def self.create_put_content_action(content_item, locale, event)
    create!(
      content_id: content_item.content_id,
      locale: locale,
      action: "PutContent",
      user_uid: event.user_uid,
      content_item: content_item,
      event: event,
    )
  end

private

  def one_of_content_item_link_set
    if content_item_id && link_set_id || content_item && link_set
      errors.add(:base, "can not be associated with both a content item and link set")
    end
  end
end
