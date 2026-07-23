/** A cell on the heatmap grid */
export class HeatmapCell {
  date: string;
  level: number;
  checkIn?: import('./CheckIn').CheckIn;

  constructor(date: string, level: number, checkIn?: import('./CheckIn').CheckIn) {
    this.date = date;
    this.level = level;
    this.checkIn = checkIn;
  }
}
