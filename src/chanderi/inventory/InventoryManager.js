export class InventoryManager {
  constructor(state,eventBus){this.state=state;this.events=eventBus;}
  has(id){return this.state.inventory.items.some(x=>x.id===id && x.qty>0);}
  add(id,name,qty=1){const item=this.state.inventory.items.find(x=>x.id===id);if(item)item.qty+=qty;else this.state.inventory.items.push({id,name,qty});this.events?.emit("inventory:changed",this.state.inventory);}
  remove(id,qty=1){const item=this.state.inventory.items.find(x=>x.id===id);if(!item||item.qty<qty)return false;item.qty-=qty;this.state.inventory.items=this.state.inventory.items.filter(x=>x.qty>0);this.events?.emit("inventory:changed",this.state.inventory);return true;}
}
