package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	students := getStudentDetails()
	fmt.Fprintf(w, "%-4s %-8s %-7s %-5s\n", "Id", "Name", "Score", "Grade")

	for _, student := range students {
		Grade := getGrades(student)
		fmt.Fprintf(w, "%-4d %-8s %-7d %-5s\n", student.Id, student.Name, student.Score, Grade)
	}
}
func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server running on port 9090...")
	http.ListenAndServe(":9090", nil)
}
