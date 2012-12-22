module MatchesHelper
  def match_type(match)
    case match.match_type
      when Match::MATCH_TYPE_TEST then 'Test'
      when Match::MATCH_TYPE_ODI then 'One Day International'
    end
  end
end
