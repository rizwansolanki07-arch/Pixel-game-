export class MapManager {
  constructor(maps){this.maps=maps;}
  get(id){return this.maps.maps[id]||null;}
  canEnter(id){return !!this.get(id);}
}
