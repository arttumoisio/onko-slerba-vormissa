export interface WZData {
  matches: WZMatch[];
  summary: {};
}

export interface WZMatch {
  utcStartSeconds: number;
  utcEndSeconds: number;
  map: string;
  mode: string;
  matchID: number;
  duration: number;
  playlistName: null;
  version: number;
  gameType: string;
  playerCount: number;
  playerStats: WZPlayerStats;
  player: WZPlayer;
}

export interface WZPlayerStats {
  kills: number;
  deaths: number;
  headshots: number;
  assists: number;
  rank: number;
  gulagKills: number;
  gulagDeaths: number;
  longestStreak: number;
  teamPlacement: number;
  damageDone: number;
  damageTaken: number;
}

export interface WZPlayer {
  team: string;
  rank: number;
  awards: {};
  username: string;
  uno: string;
  clantag: string;
  brMissionStats: WZbrMissionStats;
  loadout: WZLoadout[];
}

export type IAvailableUsers =
  | "Slerba"
  | "Kyntö"
  | "Hojo"
  | "Kupperi"
  | undefined;

export enum AvailableUsersValue {
  Slerba = "rekyylireijo33#5266178",
  Kyntö = "kyntö#1293018",
  Hojo = "hojozza#2398418",
  Kupperi = "kupperi#3370706",
}

export const Karmivat = Object.values(AvailableUsersValue);

export enum Mode {
  Solos = "br_brsolos",
  Duos = "br_brduos",
  Trios = "br_brtrios",
  Quads = "br_brquads",
  Plunder = "br_dmz_plnbld",
  BuyBackQuads = "br_brbbquad",
}

export interface WZLoadout {
  primaryWeapon: WZWeapon;
  secondaryWeapon: WZWeapon;
  perks: [];
  extraPerks: [];
  killstreaks: [];
  tactical: object;
  lethal: object;
}

export interface WZWeapon {
  name: string;
  label: null;
  imageLoot: null;
  imageIcon: null;
  variant: number;
  attachments: [];
}

export interface WZbrMissionStats {
  missionsComplete: number;
  totalMissionXpEarned: number;
  totalMissionWeaponXpEarned: number;
  missionStatsByType: {};
}
