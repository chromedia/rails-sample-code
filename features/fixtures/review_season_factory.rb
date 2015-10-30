class ReviewSeasonFactory
  def self.create_current
    create(Date.today - 1.day, Date.today + 1.month)
  end

  def self.create_previous
    create(Date.today - 1.month, Date.today - 1.day)
  end

  def self.create(season_start, season_end)
    ReviewSeason.create!(
        season: 'May 2014',
        season_start: season_start,
        season_end: season_end,
        first_timer: 17000,
        repeater: 10000,
        full_review: 17000,
        double_review: 22000,
        coaching: 7000,
        reservation: 3000
    )
  end
end