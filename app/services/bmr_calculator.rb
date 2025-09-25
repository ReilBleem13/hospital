class BmrCalculator
    class UnsupportedFormulaError < StandardError; end
    class InvalidParamsError < StandardError; end

    def self.calculate!(formula:, sex:, weight_kg:, height_cm:, age_years:)
        raise InvalidParamsError, "sex must be male or female" unless %w[male female].include?(sex)
        raise InvalidParamsError, "weight_kg, height_cm, age_years must be positive" unless weight_kg.to_f > 0 && height_cm.to_f > 0 && age_years.to_f > 0
        
        case formula
        when "mifflin_san_jeor"
            mifflin_san_jeor(sex: sex, weight_kg: weight_kg.to_f, height_cm: height_cm.to_f,  age_years: age_years.to_f)
        when "harris_benedict"
            harris_benedict(sex: sex, weight_kg: weight_kg.to_f, height_cm: height_cm.to_f,  age_years: age_years.to_f)
        else
            raise UnsupportedFormulaError, "Unsupported formula: #{formula}"
        end.round(2)
    end

    # Миффлина – Сан Жеора:
    # Мужчины: BMR = 10W + 6.25H − 5A + 5
    # Женщины: BMR = 10W + 6.25H − 5A − 161
    def self.mifflin_san_jeor(sex:, weight_kg:, height_cm:, age_years:)
        base = (10 * weight_kg) + (6.25 * height_cm) - (5 * age_years)
        sex == "male" ? base + 5 : base - 161
    end

    # Харриса–Бенедикта:
    # Мужчины: BMR = 88.362 + 13.397W + 4.799H − 5.677A
    # Женщины: BMR = 447.593 + 9.247W + 3.098H − 4.330A
    def self.harris_benedict(sex:, weight_kg:, height_cm:, age_years:)
        if sex == "male"
            88.362 + (13.397 * weight_kg) + (4.799 * height_cm) - (5.677 * age_years)
        else
            447.593 + (9.247 * weight_kg) + (3.098 * height_cm) - (4.330 * age_years)
        end
    end
end