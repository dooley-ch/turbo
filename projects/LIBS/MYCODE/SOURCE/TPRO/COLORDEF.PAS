Unit Colordef;
{Contributed by W.G. Madison and Associates, Ltd.}

Interface

const

        {Color constants:
         Black     = 0; Blue   = 1; Green   = 2; Cyan   = 3; Red   = 4;
         Magenta   = 5; Brown  = 6; LtGray  = 7;
         DkGray    = 8; LtBlue = 9; LtGreen = A; LtCyan = B; LtRed = C;
         LtMagenta = D; Yellow = E; White   = F
         }

        {Screen color constants}
        BlackOnBlack       = $00;          BlueOnBlack        = $01;
        BlackOnBlue        = $10;          BlueOnBlue         = $11;
        BlackOnGreen       = $20;          BlueOnGreen        = $21;
        BlackOnCyan        = $30;          BlueOnCyan         = $31;
        BlackOnRed         = $40;          BlueOnRed          = $41;
        BlackOnMagenta     = $50;          BlueOnMagenta      = $51;
        BlackOnBrown       = $60;          BlueOnBrown        = $61;
        BlackOnLtGray      = $70;          BlueOnLtGray       = $71;

        GreenOnBlack       = $02;          CyanOnBlack        = $03;
        GreenOnBlue        = $12;          CyanOnBlue         = $13;
        GreenOnGreen       = $22;          CyanOnGreen        = $23;
        GreenOnCyan        = $32;          CyanOnCyan         = $33;
        GreenOnRed         = $42;          CyanOnRed          = $43;
        GreenOnMagenta     = $52;          CyanOnMagenta      = $53;
        GreenOnBrown       = $62;          CyanOnBrown        = $63;
        GreenOnLtGray      = $72;          CyanOnLtGray       = $73;

        RedOnBlack         = $04;          MagentaOnBlack     = $05;
        RedOnBlue          = $14;          MagentaOnBlue      = $15;
        RedOnGreen         = $24;          MagentaOnGreen     = $25;
        RedOnCyan          = $34;          MagentaOnCyan      = $35;
        RedOnRed           = $44;          MagentaOnRed       = $45;
        RedOnMagenta       = $54;          MagentaOnMagenta   = $55;
        RedOnBrown         = $64;          MagentaOnBrown     = $65;
        RedOnLtGray        = $74;          MagentaOnLtGray    = $75;

        BrownOnBlack       = $06;          LtGrayOnBlack      = $07;
        BrownOnBlue        = $16;          LtGrayOnBlue       = $17;
        BrownOnGreen       = $26;          LtGrayOnGreen      = $27;
        BrownOnCyan        = $36;          LtGrayOnCyan       = $37;
        BrownOnRed         = $46;          LtGrayOnRed        = $47;
        BrownOnMagenta     = $56;          LtGrayOnMagenta    = $57;
        BrownOnBrown       = $66;          LtGrayOnBrown      = $67;
        BrownOnLtGray      = $76;          LtGrayOnLtGray     = $77;

        DkGrayOnBlack      = $08;          LtBlueOnBlack      = $09;
        DkGrayOnBlue       = $18;          LtBlueOnBlue       = $19;
        DkGrayOnGreen      = $28;          LtBlueOnGreen      = $29;
        DkGrayOnCyan       = $38;          LtBlueOnCyan       = $39;
        DkGrayOnRed        = $48;          LtBlueOnRed        = $49;
        DkGrayOnMagenta    = $58;          LtBlueOnMagenta    = $59;
        DkGrayOnBrown      = $68;          LtBlueOnBrown      = $69;
        DkGrayOnLtGray     = $78;          LtBlueOnLtGray     = $79;

        LtGreenOnBlack     = $0A;          LtCyanOnBlack      = $0B;
        LtGreenOnBlue      = $1A;          LtCyanOnBlue       = $1B;
        LtGreenOnGreen     = $2A;          LtCyanOnGreen      = $2B;
        LtGreenOnCyan      = $3A;          LtCyanOnCyan       = $3B;
        LtGreenOnRed       = $4A;          LtCyanOnRed        = $4B;
        LtGreenOnMagenta   = $5A;          LtCyanOnMagenta    = $5B;
        LtGreenOnBrown     = $6A;          LtCyanOnBrown      = $6B;
        LtGreenOnLtGray    = $7A;          LtCyanOnLtGray     = $7B;

        LtRedOnBlack       = $0C;          LtMagentaOnBlack   = $0D;
        LtRedOnBlue        = $1C;          LtMagentaOnBlue    = $1D;
        LtRedOnGreen       = $2C;          LtMagentaOnGreen   = $2D;
        LtRedOnCyan        = $3C;          LtMagentaOnCyan    = $3D;
        LtRedOnRed         = $4C;          LtMagentaOnRed     = $4D;
        LtRedOnMagenta     = $5C;          LtMagentaOnMagenta = $5D;
        LtRedOnBrown       = $6C;          LtMagentaOnBrown   = $6D;
        LtRedOnLtGray      = $7C;          LtMagentaOnLtGray  = $7D;

        YellowOnBlack      = $0E;          WhiteOnBlack       = $0F;
        YellowOnBlue       = $1E;          WhiteOnBlue        = $1F;
        YellowOnGreen      = $2E;          WhiteOnGreen       = $2F;
        YellowOnCyan       = $3E;          WhiteOnCyan        = $3F;
        YellowOnRed        = $4E;          WhiteOnRed         = $4F;
        YellowOnMagenta    = $5E;          WhiteOnMagenta     = $5F;
        YellowOnBrown      = $6E;          WhiteOnBrown       = $6F;
        YellowOnLtGray     = $7E;          WhiteOnLtGray      = $7F;

Implementation

end.
