# name: discourse-category-flair-mapping
# about: Allows to choose avatar flair groups per category
# version: 1.0.1
# authors: Communiteq
# url: https://github.com/communiteq/discourse-category-flair-mapping

enabled_site_setting :category_flair_mapping_enabled

after_initialize do
  module CategoryFlairMapping
    module PostSerializerExtension
      def flair_name
        return object.user&.flair_group_for_category(object.topic&.category)&.name
      end
      def flair_url
        return object.user&.flair_group_for_category(object.topic&.category)&.flair_url
      end
      def flair_bg_color
        return object.user&.flair_group_for_category(object.topic&.category)&.flair_bg_color
      end
      def flair_color
        return object.user&.flair_group_for_category(object.topic&.category)&.flair_color
      end
      def flair_group_id
        return object.user&.flair_group_for_category(object.topic&.category)&.id
      end
    end
  end

  add_to_class(:user, :flair_group_for_category) do |category|
    @memoized_flair_group_for_category ||= {}
    return @memoized_flair_group_for_category[category&.id] if @memoized_flair_group_for_category[category&.id]

    if category
      category_flair_groups = category&.custom_fields&.[]('avatar_flair_groups')&.split(',')&.map(&:to_i) || []
      custom_group_id = (category_flair_groups & group_ids).first
      if custom_group_id
        custom_group = Group.find(custom_group_id)
        @memoized_flair_group_for_category[category.id] = custom_group
        return custom_group
      end
      @memoized_flair_group_for_category[category.id] = flair_group
    end
    flair_group
  end

  reloadable_patch do |plugin|
    ::PostSerializer.prepend CategoryFlairMapping::PostSerializerExtension
  end

  Site.preloaded_category_custom_fields << 'avatar_flair_groups'
end

