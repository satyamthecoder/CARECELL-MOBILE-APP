package com.carecell.enums;

public enum BloodGroup {
    A_POSITIVE("A+"),
    A_NEGATIVE("A-"),
    B_POSITIVE("B+"),
    B_NEGATIVE("B-"),
    AB_POSITIVE("AB+"),
    AB_NEGATIVE("AB-"),
    O_POSITIVE("O+"),
    O_NEGATIVE("O-");

    private final String display;

    BloodGroup(String display) { this.display = display; }

    public String getDisplay() { return display; }

    /** Returns blood groups compatible as donor for this recipient group */
    public static java.util.List<BloodGroup> compatibleDonorsFor(BloodGroup recipient) {
        return switch (recipient) {
            case A_POSITIVE  -> java.util.List.of(A_POSITIVE, A_NEGATIVE, O_POSITIVE, O_NEGATIVE);
            case A_NEGATIVE  -> java.util.List.of(A_NEGATIVE, O_NEGATIVE);
            case B_POSITIVE  -> java.util.List.of(B_POSITIVE, B_NEGATIVE, O_POSITIVE, O_NEGATIVE);
            case B_NEGATIVE  -> java.util.List.of(B_NEGATIVE, O_NEGATIVE);
            case AB_POSITIVE -> java.util.List.of(values()); // universal recipient
            case AB_NEGATIVE -> java.util.List.of(A_NEGATIVE, B_NEGATIVE, AB_NEGATIVE, O_NEGATIVE);
            case O_POSITIVE  -> java.util.List.of(O_POSITIVE, O_NEGATIVE);
            case O_NEGATIVE  -> java.util.List.of(O_NEGATIVE);
        };
    }
}
