export const SAVE_KEY = "chanderi_quest_save_v1";

export function saveGame(state) {
  const payload = {
    version: 1,
    savedAt: new Date().toISOString(),
    state: structuredClone(state)
  };
  localStorage.setItem(SAVE_KEY, JSON.stringify(payload));
  return payload;
}

export function loadGame() {
  const raw = localStorage.getItem(SAVE_KEY);
  if (!raw) return null;
  try {
    const payload = JSON.parse(raw);
    if (!payload || payload.version !== 1 || !payload.state) return null;
    return payload;
  } catch {
    return null;
  }
}

export function clearSave() {
  localStorage.removeItem(SAVE_KEY);
}
