package main

func getGrades(s student) string {
	Grade := ""
	if s.Score >= 90 && s.Score <= 100 {
		Grade = "A"
	} else if s.Score >= 80 && s.Score <= 89 {
		Grade = "B"
	} else if s.Score >= 70 && s.Score <= 79 {
		Grade = "C"
	} else if s.Score >= 60 && s.Score <= 69 {
		Grade = "D"
	} else {
		Grade = "F"
	}
	return Grade
}
