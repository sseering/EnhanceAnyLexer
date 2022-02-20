module config
import os

pub struct RegexSetting {
pub mut:
	regex string
	color int
}

pub fn (rs RegexSetting) str() string {
	return '[$rs.regex, $rs.color]'
}


pub struct Lexers {
pub mut:
	name string
	regexes []RegexSetting
	excluded_styles []int
}
pub fn (l Lexers) str() string {
	mut regexes_ := ''
	mut styles_ := ''
	for regex in l.regexes { regexes_ += '${regex.str()} ' }
	for style in l.excluded_styles { styles_ += '${style.str()} ' }
	return '[$l.name, $regexes_, $styles_]'
}


pub struct Config {
pub mut:
	all []Lexers
	current Lexers
}

pub fn read(config_file string) {
	content := os.read_file(config_file) or { return }
	lines := content.split_into_lines()
	mut lexers := Lexers{}
	mut setting := RegexSetting{}
	plugin.lexers_to_enhance = Config{}
	
	for line in lines {
		mut line_ := line.trim(' ')
		if line_.starts_with(';') || line.len == 0 { 
			continue 
		}
		else if line_.starts_with('[') {
			if lexers.name != '' {
				plugin.lexers_to_enhance.all << lexers
				lexers = Lexers{}
			}
			lexers.name = line_.trim("[]").trim(' ').to_lower()
			setting = RegexSetting{}
		} 
		else if line_.starts_with('indicator_id') {
			indicator_id := line_.split('=')
			if indicator_id.len == 2 {
				indicator_id_ := indicator_id[1].trim(' ')
				plugin.indicator_id = indicator_id_.int()
			}
		}
		else if line_.starts_with('debug_mode') {
			debug_mode := line_.split('=')
			if debug_mode.len == 2 {
				debug_mode_ := debug_mode[1].trim(' ')
				plugin.debug_mode = debug_mode_.int() == 1
			}
		} else {
			if line_.starts_with('excluded_styles') {
				excludes := line_.split('=')
				if excludes.len == 2 {
					ids := excludes[1].split(',')
					for id in ids {
						trimmed_id := id.trim(' ')
						lexers.excluded_styles << trimmed_id.int()
					}
				}
			} else {
				split_pos := line_.index('=') or { continue }
				if split_pos > 0 {
					setting.color = line_[0..split_pos].trim(' ').int()
					regex := line_[split_pos..].trim_left('=')
					if regex.len > 0 {
						setting.regex = regex.trim(' ')
						lexers.regexes << setting
					}
				}
			}
		}
	}
	plugin.lexers_to_enhance.all << lexers
}