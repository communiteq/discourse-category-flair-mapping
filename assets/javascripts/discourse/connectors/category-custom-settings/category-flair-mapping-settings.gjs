import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action, computed } from "@ember/object";
import { inject as service } from "@ember/service";
import GroupChooser from "select-kit/components/group-chooser";
import i18n from "discourse-common/helpers/i18n";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";


export default class CategoryFlairMappingSettings extends Component {
  @service site;
  @service siteSettings;
  @tracked selectedGroups = null;

  constructor() {
    super(...arguments);
    this.updateSelectedGroups(); // Run initially
  }

  updateSelectedGroups() {
    if (!this.args.outletArgs.category) {
      this.selectedGroups = [];
      return;
    }

    let groupIds = (this.args.outletArgs.category.custom_fields.avatar_flair_groups || "")
      .split(",")
      .filter(Boolean)
      .map((id) => parseInt(id, 10));

    this.selectedGroups = this.site.groups
      .filter((group) => groupIds.includes(group.id))
      .map((group) => group.name);
  }

  @action
  refreshOnCategoryChange() {
    this.updateSelectedGroups();
  }

  @computed("site.groups.[]")
  get availableGroups() {
    return (this.site.groups || [])
      .map((g) => { // don't list "everyone"
        return g.id === 0 ? null : g.name;
      })
      .filter(Boolean);
  }

  @action
  onChangeGroups(groupNames) {
    this.selectedGroups = groupNames;

    let groupIds = this.site.groups
      .filter((group) => groupNames.includes(group.name))
      .map((group) => group.id);

    this.args.outletArgs.category.custom_fields.avatar_flair_groups = groupIds.join(",");
  }

  <template>
    <div
      {{didInsert this.refreshOnCategoryChange}}
      {{didUpdate this.refreshOnCategoryChange this.args.outletArgs.category}}>
      <section>
        <h3>{{i18n "category.category_flair_mapping.title"}}</h3>
      </section>
      <section class="field">
        <label>
          {{i18n "category.category_flair_mapping.avatar_flair_groups_description"}}
        </label>
        <div class="value">
          <GroupChooser
            @content={{this.availableGroups}}
            @valueProperty={{null}}
            @nameProperty={{null}}
            @value={{this.selectedGroups}}
            @onChange={{this.onChangeGroups}}
          />
        </div>
      </section>
    </div>
  </template>
};