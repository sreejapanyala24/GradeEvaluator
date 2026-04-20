package main

type student struct {
	Id    int
	Name  string
	Score int
}

func getStudentDetails() []student {
	students := []student{
		{1, "Sarayu", 94},
		{2, "Priya", 77},
		{3, "Arjun", 64},
		{4, "Vikram", 85},
		{5, "Shyam", 60},
		{6, "Teja", 98},
	}
	return students
}
