export interface WZData {
    matches: WZMatch[];
};
  
export interface WZMatch {
    utcStartSeconds: number;
    utcEndSeconds: number;
    map: string;
    mode: string;
    matchID: number;
    duration: number;
    playlistName: null,
    version: number;
    gameType: string;
    playerCount: number;
    playerStats: WZPlayerStats;
    player: WZPlayer;
};

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
};
  
export interface WZPlayer {
    team: string;
    rank: number;
    awards: {};
    username: string;
    uno: string;
    clantag: string;
    brMissionStats: WZbrMissionStats;
    loadout: WZLoadout[]
};

export interface WZLoadout {
    primaryWeapon:  WZWeapon;
    secondaryWeapon:  WZWeapon;
    perks: [];
    extraPerks: [];
    killstreaks: [];
    tactical:  object;
    lethal: object;
};

export interface WZWeapon {
    name: string;
    label: null;
    imageLoot: null;
    imageIcon: null;
    variant: number;
attachments: [];
};

export interface WZbrMissionStats {
    missionsComplete: number;
    totalMissionXpEarned: number;
    totalMissionWeaponXpEarned: number;
    missionStatsByType: {};
};
