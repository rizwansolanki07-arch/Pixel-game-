export class QuestManager {
  constructor(state,quests,eventBus){this.state=state;this.quests=quests;this.events=eventBus;}
  get current(){return this.quests.quests.find(q=>q.id===this.state.quest.id)||null;}
  setStep(step){if(this.state.quest.completed)return;this.state.quest.step=step;this.events?.emit("quest:changed",this.state.quest);}
  complete(){this.state.quest.completed=true;this.state.quest.step="complete";this.events?.emit("quest:completed",this.current);}
}
