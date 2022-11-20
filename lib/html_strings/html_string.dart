class HTMLString {
  static String getHTMLReceipt({
    required String owner,
    required String parkee,
    required String transactioDate,
    required String arrivalDate,
    required String departureDate,
    required String duration,
    required double parkingFee,
    required String spaceAddress,
  }) {
    return ''' <head>

  <meta charset="utf-8">
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <title>Email Receipt</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
    /**
   * Google webfonts. Recommended to include the .woff version for cross-client compatibility.
   */
    @media screen {
      @font-face {
        font-family: 'Source Sans Pro';
        font-style: normal;
        font-weight: 400;
        src: local('Source Sans Pro Regular'), local('SourceSansPro-Regular'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/ODelI1aHBYDBqgeIAH2zlBM0YzuT7MdOe03otPbuUS0.woff) format('woff');
      }

      @font-face {
        font-family: 'Source Sans Pro';
        font-style: normal;
        font-weight: 700;
        src: local('Source Sans Pro Bold'), local('SourceSansPro-Bold'), url(https://fonts.gstatic.com/s/sourcesanspro/v10/toadOcfmlt9b38dHJxOBGFkQc6VGVFSmCnC_l7QZG60.woff) format('woff');
      }
    }

    /**
   * Avoid browser level font resizing.
   * 1. Windows Mobile
   * 2. iOS / OSX
   */
    body,
    table,
    td,
    a {
      -ms-text-size-adjust: 100%;
      /* 1 */
      -webkit-text-size-adjust: 100%;
      /* 2 */
    }

    /**
   * Remove extra space added to tables and cells in Outlook.
   */
    table,
    td {
      mso-table-rspace: 0pt;
      mso-table-lspace: 0pt;
    }

    /**
   * Better fluid images in Internet Explorer.
   */
    img {
      -ms-interpolation-mode: bicubic;
    }

    /**
   * Remove blue links for iOS devices.
   */
    a[x-apple-data-detectors] {
      font-family: inherit !important;
      font-size: inherit !important;
      font-weight: inherit !important;
      line-height: inherit !important;
      color: inherit !important;
      text-decoration: none !important;
    }

    /**
   * Fix centering issues in Android 4.4.
   */
    div[style*="margin: 16px 0;"] {
      margin: 0 !important;
    }

    body {
      width: 100% !important;
      height: 100% !important;
      padding: 0 !important;
      margin: 0 !important;
    }

    /**
   * Collapse table borders to avoid space between cells.
   */
    table {
      border-collapse: collapse !important;
    }

    a {
      color: #1a82e2;
    }

    img {
      height: auto;
      line-height: 100%;
      text-decoration: none;
      border: 0;
      outline: none;
    }
  </style>

</head>

<body style="background-color: #bac5d2;">

  <!-- start body -->
  <table border="0" cellpadding="0" cellspacing="0" width="100%">

    <!-- start logo -->
    <tr>
      <td align="center" bgcolor="#1aa7ec">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
          <tr>
            <td align="center" valign="top" style="padding: 36px 24px;">
              <a href="https://sendgrid.com" target="_blank" style="display: inline-block;">
                <img src="https://firebasestorage.googleapis.com/v0/b/let-s-park-5c05c.appspot.com/o/app%2Flets-park-logo.png?alt=media&token=60055306-d2bd-414e-b346-a6d4fdc157e8" alt="Logo" border="0" width="48"
                  style="display: block; width: 120px; max-width: 120px; min-width: 120px;">
              </a>
            </td>
          </tr>
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end logo -->

    <!-- start hero -->
    <tr>
      <td align="center" bgcolor="#bac5d2">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">
          <tr>
            <td align="left" bgcolor="#ffffff"
              style="padding: 36px 24px 0; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; border-top: 3px solid #8cd3ff;">
              <h1 style="margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -1px; line-height: 48px;">Parking session receipt</h1>
            </td>
          </tr>
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end hero -->

    <!-- start copy block -->
    <tr>
      <td align="center" bgcolor="#bac5d2">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">

          <!-- start copy -->
          <tr>
            <td align="left" bgcolor="#ffffff"
              style="padding: 24px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
              <p style="margin: 0;">Here is a summary of your recent parking. If you have any questions or concerns about
                your parking, you can always contact the caretaker or reply in this email.</p><br>
                <span><strong>Parking space owner:</strong> $owner</span><br>
                <span><strong>Parkee:</strong> $parkee</span><br>
                <span><strong>Transaction date:</strong> $transactioDate</span>
           
            </td>
          </tr>
          
          <!-- end copy -->

          <!-- start receipt table -->
          <tr>
            <td align="left" bgcolor="#ffffff"
              style="padding: 24px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
              <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td align="left" bgcolor="#f5f7fa" width="75%"
                    style="padding: 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    <strong style="color: #1aa7ec;">Parking session #</strong></td>
                  <td align="left" bgcolor="#f5f7fa" width="25%"
                    style="padding: 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    <strong style="color: #1aa7ec;">1720221413361</strong></td>
                </tr>
                <tr>
                  <td align="left" width="75%"
                    style="padding: 6px 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    Arrival</td>
                  <td align="left" width="25%"
                    style="padding: 6px 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    $arrivalDate</td>
                </tr>
                <tr>
                  <td align="left" width="75%"
                    style="padding: 6px 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    Departure</td>
                  <td align="left" width="25%"
                    style="padding: 6px 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    $departureDate</td>
                </tr>
                <tr>
                  <td align="left" width="75%"
                    style="padding: 6px 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    Duration</td>
                  <td align="left" width="25%"
                    style="padding: 6px 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    $duration</td>
                </tr>
                <tr>
                  <td align="left" width="75%"
                    style="padding: 12px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px; border-top: 2px dashed #8cd3ff; border-bottom: 2px dashed #8cd3ff;">
                    <strong>Parking fee</strong></td>
                  <td align="left" width="25%"
                    style="padding: 12px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px; border-top: 2px dashed #8cd3ff; border-bottom: 2px dashed #8cd3ff;">
                    <strong>$parkingFee</strong></td>
                </tr>
                <tr><td><br></td></tr>
                <tr>
                  <td align="left" bgcolor="#f5f7fa" width="75%"
                    style="padding: 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    <strong style="color: #1aa7ec;">Parking space addreess </strong></td>
                  <td align="left" bgcolor="#f5f7fa" width="25%"
                    style="padding: 12px;font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 16px; line-height: 24px;">
                    </td>
                </tr>
                <tr>
                  <td style="padding: 12px;">
                    <p>$spaceAddress</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- end reeipt table -->
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end copy block -->

    <!-- start receipt address block -->
    <tr>
      <td align="center" bgcolor="#bac5d2" valign="top" width="100%">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table align="center" bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="100%"
          style="max-width: 600px;">
          <tr>
            <td align="center" valign="top" style="font-size: 0; border-bottom: 3px solid #8cd3ff">
              <!--[if (gte mso 9)|(IE)]>
              <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
              <tr>
              <td align="left" valign="top" width="300">
              <![endif]-->

              <!--[if (gte mso 9)|(IE)]>
              </td>
              <td align="left" valign="top" width="300">
              <![endif]-->
              
              <!--[if (gte mso 9)|(IE)]>
              </td>
              </tr>
              </table>
              <![endif]-->
            </td>
          </tr>
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end receipt address block -->

    <!-- start footer -->
    <tr>
      <td align="center" bgcolor="#1aa7ec" style="padding: 24px;">
        <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">
        <tr>
        <td align="center" valign="top" width="600">
        <![endif]-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width: 600px;">

          <!-- start permission -->
          <tr>
            <td align="center" bgcolor="#1aa7ec"
              style="padding: 12px 24px; font-family: 'Source Sans Pro', Helvetica, Arial, sans-serif; font-size: 14px; line-height: 20px; color: #666;">
              <p style="margin: 0; color: #fff;">A parking receipt will always be sent to your email after a booking. Make sure to present this email at the caretaker when arrived at the parking area.</p>
            </td>
          </tr>
          <!-- end permission -->

        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
      </td>
    </tr>
    <!-- end footer -->

  </table>
  <!-- end body -->

</body> ''';
  }
}
