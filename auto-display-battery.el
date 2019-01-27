;;; auto-display-battery.el --- Automatically turn `display-battery-mode' on and off -*- lexical-binding: t -*-

;; Copyright (c) 2019 Daniel Kraus <daniel@kraus.my>

;; Author: Daniel Kraus <daniel@kraus.my>
;; URL: https://github.com/dakra/auto-display-battery.el
;; Keywords: auto-display-battery, mobile, phone, convenience, tools
;; Version: 0.1
;; Package-Requires: ((emacs "25.2"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; When my Laptop is connected to a power source I don't want to see
;; the battery status.
;; This mode turns `display-battery-mode' on when the Laptop
;; is running on battery or switches it off if it's connected to power.

;;; Code:

(require 'dbus)

(defun auto-display-battery-toggle-display-battery (_string values _)
  "Toggle function `display-battery-mode' depending if line power is online.
VALUES is an alist from the \"line_power_AC\" signal."
  (if (caadr (assoc-string "Online" values))
      (display-battery-mode -1)
    (display-battery-mode)))


;;; Minor mode

;;;###autoload
(define-minor-mode auto-display-battery-mode
  "Automatically show hide battery status of your Laptop."
  :global t
  (if (not auto-display-battery-mode)
      (dbus-unregister-service :system
        "org.freedesktop.UPower")

    (dbus-register-signal :system
      "org.freedesktop.UPower"
      "/org/freedesktop/UPower/devices/line_power_AC"
      "org.freedesktop.DBus.Properties"
      "PropertiesChanged"
      #'auto-display-battery-toggle-display-battery)

    (when (car (dbus-call-method :system
                 "org.freedesktop.UPower"
                 "/org/freedesktop/UPower/devices/line_power_AC"
                 "org.freedesktop.DBus.Properties"
                 "Get" "org.freedesktop.UPower.Device" "Online"))
      (display-battery-mode))))

(provide 'auto-display-battery)
;;; auto-display-battery.el ends here
