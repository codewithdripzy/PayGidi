package utils

import "time"

func FormatToVfdDate(dateStr string) (string, error) {
	layout := "2002-01-20"
	parsedDate, err := time.Parse(layout, dateStr)
	if err != nil {
		return "", err
	}

	return parsedDate.Format("2002-01-20"), nil
}
