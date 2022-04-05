module main

import net.http
import x.json2
import rand

pub const (
	reset   = '\x1b[39m'
	blue    = '\x1b[34m'
	cyan    = '\x1b[36m'
	red     = '\x1b[31m'
	magenta = '\x1b[35m'
	green   = '\x1b[32m'
	clear   = '\033[2J\033[1;1H'
)

[params]
struct Email_data {
	email_name string
	email_pass string
}

pub fn debug(debug_mode bool) ?string {
	if debug_mode == true {
		status := '$magenta[+]$reset$green Debug mode enabled$reset'
		return status
	} else if debug_mode == false {
		status := '$magenta[+]$reset$red Debug mode disabled$reset'
		return status
	}
	status := '$red[-]$reset Error with debug status module...'
	return status
}

pub fn client()

pub fn get_domains(base_url string, debug_mode bool) ?[]string {
	mut domains := []string{}
	text := http.get_text(base_url + '/domains')
	data := (json2.raw_decode(text) ?).as_map()
	entries := data['hydra:member'] ?.arr()

	for entry in entries {
		domain := entry.as_map()['domain'] ?
		domains << domain.str()
		if debug_mode == true {
			for key, value in entry.as_map() {
				println(key)
				println(value)
				println(domains)
				println(entry)
				println(domain)
			}
		}
	}
	return domains
}

pub fn create_email(base_url string, debug_mode bool, email_data Email_data) ?[]string {
	mut emails := []string{}
	mut email := ''
	mut pass := ''
	if email_data.email_name == '' {
		email = rand.string(8).to_lower()
	} else {
		email = email_data.email_name.to_lower()
	}
	if email_data.email_pass == '' {
		pass = rand.string(12)
	} else {
		pass = email_data.email_pass
	}

	mail := email + '@' + get_domains(base_url, debug_mode) ?[0]

	data := {
		'address':  mail
		'password': pass
	}

	cleaned_data := data.str().replace("'", '"')

	response := http.post_json(base_url + '/accounts', cleaned_data) ?
	token := get_token(base_url, mail, pass, debug_mode) ?

	full_data := {
		'address':  mail
		'password': pass
		'token':    token[0]
	}
	cleaned_full_data := full_data.str().replace("'", '"')

	if response.status_code == 201 {
		println('$magenta[+]$reset$green Account resource created!$reset')

		if token[0] == '' {
		} else {
			emails << cleaned_full_data.str()
		}
	} else if response.status_code == 400 {
		println('$magenta[/]$reset$red Invalid input, please enter a valid [a-z] [A-Z] [0-9] string or leave value blank...$reset')
	} else if response.status_code == 422 {
		println('$magenta[/]$reset$red Unprocessable entity, this address might already be in use...$reset')
	} else if response.status_code == 404 {
		println('$magenta[-]$reset$red Request failed...$reset')
	} else if response.status_code == 500 {
		println('$magenta[-]$reset$red Internal server error, You might be rate limited...$reset')
		if token[0] == '' {
		} else {
			emails << cleaned_full_data.str()
		}
	} else {
		println('$magenta[-]$reset$red Error: $response.status_code $reset')
	}

	return emails
}

pub fn get_token(base_url string, mail string, pass string, debug_mode bool) ?[]string {
	mut tokens := []string{}
	// mut mail := email
	// mut pass := pass
	data := {
		'address':  mail
		'password': pass
	}

	cleaned_data := data.str().replace("'", '"')
	response := http.post_json(base_url + '/token', cleaned_data) ?

	// token := (json2.raw_decode(response.text) ?).as_map()["token"]
	token := json2.raw_decode(response.text) ?.as_map()['token'] ?

	if response.status_code == 200 {
		tokens << token.str()
		println('$magenta[+]$reset$green Account information is valid!$reset')
	} else {
		println('$magenta[-]$reset$red Error: Invalid account information. Status code: $response.status_code $reset')
	}

	return tokens
}

pub fn fetch_inbox(base_url string, emails []string, debug_mode bool) ?[]string {
	mut inbox := []string{}
	token := json2.raw_decode(emails[0]) ?.as_map()['token']
	header := http.new_header_from_map({
		.authorization: 'Bearer $token',
	})

	response := http.fetch(header: header, url: base_url + '/messages') ?
	data := (json2.raw_decode(response.text) ?).as_map()
	entries := data['hydra:member'] ?.arr()

	for entry in entries {
		println(entry)
		inbox << entry.str()
	}
	return inbox
}

pub fn get_message(base_url string, emails []string, message_id string, debug_mode bool) ?[]string {
	mut message := []string{}
	token := json2.raw_decode(emails[0]) ?.as_map()['token']
	header := http.new_header_from_map({
		.authorization: 'Bearer $token',
	})

	response := http.fetch(header: header, url: base_url + '/messages' + message_id) ?
	data := (json2.raw_decode(response.text) ?).as_map()
	entries := data ?.arr()

	for entry in entries {
		println(entry)
		message << entry.str()
	}
	return message
}

pub fn get_message_content(base_url string, emails []string, message_id string, debug_mode bool) ?[]string {
	mut contents := []string{}
	token := json2.raw_decode(emails[0]) ?.as_map()['token']
	header := http.new_header_from_map({
		.authorization: 'Bearer $token',
	})

	response := http.fetch(header: header, url: base_url + '/messages') ?
	data := (json2.raw_decode(response.text) ?).as_map()
	entries := data['text'] ?.arr()

	for entry in entries {
		println(entry)
		contents << entry.str()
	}
	return contents
}

fn main() {
	mut base_url := 'https://api.mail.gw'
	mut debug_mode := false

	debug(debug_mode) ?

	// email := create_email(base_url, debug_mode) ?
	// println(email)
	// inbox := fetch_inbox(base_url, email, debug_mode) ?
	// println(inbox)
	// tokens := get_token(base_url, "vBMhgrey@bluebasketbooks.com.au", "ONIZLEVUIYQg", debug_mode) ?
	// println(tokens)
	// domains := get_domains(base_url, debug_mode) ?
	// println(domains)
	// message := get_message(base_url, email, message_id, debug_mode) ?
	// println(message)
	// message_content := get_message_content(base_url, email, message_id, debug_mode) ?
	// println(message_content)
}