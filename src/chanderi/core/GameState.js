export function createInitialState(){
  return {
    version:1,
    mapId:"chanderi_village",
    player:{x:48,y:174,hp:100,maxHp:100,gold:25},
    inventory:{items:[]},
    quest:{id:"quest_missing_package",step:"talk_to_innkeeper",completed:false},
    worldFlags:{},
    time:{day:1,hour:8,minute:0}
  };
}
