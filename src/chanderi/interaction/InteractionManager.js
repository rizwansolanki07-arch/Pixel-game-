export class InteractionManager {
  constructor(radius=24){this.radius=radius;}
  nearest(player,targets){let best=null,bestDistance=Infinity;for(const target of targets){const d=Math.hypot(target.x-player.x,target.y-player.y);if(d<this.radius&&d<bestDistance){best=target;bestDistance=d;}}return best;}
}
