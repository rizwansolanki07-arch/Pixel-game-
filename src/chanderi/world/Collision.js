export function clampToMap(entity,width,height,padding=10){
  entity.x=Math.max(padding,Math.min(width-padding,entity.x));
  entity.y=Math.max(padding,Math.min(height-padding,entity.y));
}
export function circleBlocked(x,y,r,rects){
  return rects.some(a=>x+r>a.x&&x-r<a.x+a.w&&y+r>a.y&&y-r<a.y+a.h);
}
