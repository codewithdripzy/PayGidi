package utils

import "testing"

func TestFormatToVfdDate(t *testing.T) {
	tests := []struct {
		name      string
		input     string
		want      string
		wantError bool
	}{
		{name: "date only", input: "1992-05-14", want: "1992-05-14", wantError: false},
		{name: "rfc3339", input: "1992-05-14T00:00:00Z", want: "1992-05-14", wantError: false},
		{name: "invalid", input: "14-05-1992", want: "", wantError: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := FormatToVfdDate(tt.input)
			if tt.wantError {
				if err == nil {
					t.Fatalf("expected error, got nil")
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if got != tt.want {
				t.Fatalf("unexpected output: got %s want %s", got, tt.want)
			}
		})
	}
}

func TestFormatToVfdDateWithBVN(t *testing.T) {
	tests := []struct {
		name      string
		input     string
		want      string
		wantError bool
	}{
		{name: "date only to bvn format", input: "1995-03-08", want: "08-Mar-1995", wantError: false},
		{name: "rfc3339 to bvn format", input: "1995-03-08T00:00:00Z", want: "08-Mar-1995", wantError: false},
		{name: "already bvn format", input: "08-Mar-1995", want: "08-Mar-1995", wantError: false},
		{name: "invalid", input: "03/08/1995", want: "", wantError: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := FormatToVfdDateWithBVN(tt.input)
			if tt.wantError {
				if err == nil {
					t.Fatalf("expected error, got nil")
				}
				return
			}

			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			if got != tt.want {
				t.Fatalf("unexpected output: got %s want %s", got, tt.want)
			}
		})
	}
}
