%   CLASS GUI_Msg
% =========================================================================
%
% DESCRIPTION
%   class to manages the about window of goGPSz
%
% EXAMPLE
%   ui = GUI_Msg.getInstance();
%
% FOR A LIST OF CONSTANTs and METHODS use doc Core_UI


%--------------------------------------------------------------------------
%               ___ ___ ___
%     __ _ ___ / __| _ | __|
%    / _` / _ \ (_ |  _|__ \
%    \__, \___/\___|_| |___/
%    |___/                    v 1.0 beta 4 ION
%
%--------------------------------------------------------------------------
%  Copyright (C) 2009-2019 Mirko Reguzzoni, Eugenio Realini
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%  A list of all the historical goGPS contributors is in CREDITS.nfo
%--------------------------------------------------------------------------
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------
% 01100111 01101111 01000111 01010000 01010011
%--------------------------------------------------------------------------

classdef GUI_Msg < handle
    
    properties (Constant, Access = 'protected')
        BG_COLOR = Core_UI.DARK_GREY_BG;
    end
    
    %% PROPERTIES GUI
    % ==================================================================================================================================================
    properties
        w_main      % Handle of the main window 
        win         % Handle to this window
        jedt        % j edit handle (java logger element)
    end    
    
    %% PROPERTIES STATUS
    % ==================================================================================================================================================
    properties (GetAccess = private, SetAccess = private)
    end
    
    %% METHOD CREATOR
    % ==================================================================================================================================================
    methods (Static)
        function this = GUI_Msg(w_main)
            % GUI_MAIN object creator
            this.init();
            this.openGUI();
            if nargin == 1
                this.w_main = w_main;
            end
        end
    end    
    %% METHODS INIT
    % ==================================================================================================================================================
    methods
        function init(this)
        end
        
        function openGUI(this)
            % Main Window ----------------------------------------------------------------------------------------------
            
            win = figure( 'Name', 'goGPS log', ...
                'Visible', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'NumberTitle', 'off', ...
                'Position', [0 0 480 720], ...
                'Resize', 'on');
            
            this.win = win;
            
            if isunix && not(ismac())
                win.Position(1) = round((win.Parent.ScreenSize(3) - win.Position(3)));
                win.Position(2) = round((win.Parent.ScreenSize(4) - win.Position(4)));
            else
                win.OuterPosition(1) = round((win.Parent.ScreenSize(3) - win.OuterPosition(3)));
                win.OuterPosition(2) = round((win.Parent.ScreenSize(4) - win.OuterPosition(4)));
            end
                        
            try
                main_vb = uix.VBox('Parent', win, ...
                    'Padding', 5, ...
                    'BackgroundColor', Core_UI.DARKER_GREY_BG);                
            catch
                log = Core.getLogger;
                log.addError('Please install GUI Layout Toolbox (https://it.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox)');
                open('GUI Layout Toolbox 2.3.1.mltbx');
                log.newLine();
                log.addWarning('After installation re-run goGPS');
                close(win);
                return;
            end
            top_bh = uix.HBox('Parent', main_vb);
            
            logo_GUI_Msg.BG_COLOR = Core_UI.DARK_GREY_BG;
            left_tbv = uix.VBox('Parent', top_bh, ...
                'BackgroundColor', logo_GUI_Msg.BG_COLOR, ...
                'Padding', 5);
            
            % Logo/title box -------------------------------------------------------------------------------------------
            
            logo_g = uix.Grid('Parent', left_tbv, ...
                'Padding', 5, ...
                'BackgroundColor', logo_GUI_Msg.BG_COLOR);
            
            logo_ax = axes( 'Parent', logo_g);
            logo_g.Widths = 64;
            logo_g.Heights = 64;
            [logo, transparency] = Core_UI.getLogo();
            logo(repmat(sum(logo,3) == 0,1,1,3)) = 0;
            logo = logo - 20;
            image(logo_ax, ones(size(logo)), 'AlphaData', transparency);
            logo_ax.XTickLabel = [];
            logo_ax.YTickLabel = [];
            axis off;
                        
            Core_UI.insertEmpty(left_tbv, logo_GUI_Msg.BG_COLOR);
            left_tbv.Heights = [82 -1];
            
            % Title Panel -----------------------------------------------------------------------------------------------
            right_tvb = uix.VBox('Parent', top_bh, ...
                'Padding', 5, ...
                'BackgroundColor', logo_GUI_Msg.BG_COLOR);

            top_bh.Widths = [106 -1];
            
            title = uix.HBox('Parent', right_tvb, ...
                'BackgroundColor', logo_GUI_Msg.BG_COLOR);
            
            txt = this.insertBoldText(title, 'goGPS', 12, Core_UI.LBLUE, 'left');
            txt.BackgroundColor = logo_GUI_Msg.BG_COLOR;
            title_l = uix.VBox('Parent', title, 'BackgroundColor', GUI_Msg.BG_COLOR);
            title.Widths = [60 -1];
            Core_UI.insertEmpty(title_l, logo_GUI_Msg.BG_COLOR)
            txt = this.insertBoldText(title_l, ['- software V' Core.GO_GPS_VERSION], 9, [], 'left');
            txt.BackgroundColor = logo_GUI_Msg.BG_COLOR;
            title_l.Heights = [2, -1];
            
            % Disclaimer Panel -----------------------------------------------------------------------------------------------
            Core_UI.insertEmpty(right_tvb, logo_GUI_Msg.BG_COLOR)
             txt = this.insertText(right_tvb, {'A GNSS processing software powered by GReD'}, 9, [], 'left');
             txt.BackgroundColor = logo_GUI_Msg.BG_COLOR;            
            right_tvb.Heights = [25 3 -1];
            
            % Logging Panel --------------------------------------------------------------------------------------------------
            log_container = uix.VBox('Parent', main_vb, 'Padding', 5, 'BackgroundColor', GUI_Msg.BG_COLOR);
            [j_edit_box, h_log_panel] = Core_UI.insertLog(log_container);
            this.win.UserData = struct('jedt', j_edit_box);
            this.jedt = j_edit_box;
            
            Core_UI.logMessage(j_edit_box, ['<p>Welcome to goGPS!!!</p>for any problem contact us at <a color="' rgb2hex(Core_UI.LBLUE) '" source="http://bit.ly/goGPS">http://bit.ly/goGPS</a> ^_^']);
%             Core_UI.logMessage(j_edit_box, 'a warning message...', 'warn');
%             Core_UI.logMessage(j_edit_box, 'an error message!!!', 'error');
%             Core_UI.logMessage(j_edit_box, 'a marked message again...', 'marked');
%             Core_UI.logMessage(j_edit_box, 'a regular message again...');

            % Manage dimension -------------------------------------------------------------------------------------------
            
            main_vb.Heights = [84 -1];
                        
            this.win.Visible = 'on';    
        end                
    end
    %% METHODS INSERT
    % ==================================================================================================================================================
    methods (Static)
        function txt = insertBoldText(parent, title, font_size, color, alignment)
            if nargin < 4 || isempty(color)
                color = Core_UI.WHITE;
            end
            if nargin < 5 || isempty(alignment)
                alignment = 'center';
            end
            txt = uicontrol('Parent', parent, ...
                'Style', 'Text', ...
                'String', title, ...
                'ForegroundColor', color, ...
                'HorizontalAlignment', alignment, ...
                'FontSize', Core_UI.getFontSize(font_size), ...
                'FontWeight', 'bold', ...
                'BackgroundColor', GUI_Msg.BG_COLOR);
        end

        function txt = insertText(parent, title, font_size, color, alignment)
            if nargin < 4 || isempty(color)
                color = Core_UI.WHITE;
            end
            if nargin < 5 || isempty(alignment)
                alignment = 'center';
            end
            txt = uicontrol('Parent', parent, ...
                'Style', 'Text', ...
                'String', title, ...
                'ForegroundColor', color, ...
                'HorizontalAlignment', alignment, ...
                'FontSize', Core_UI.getFontSize(font_size), ...
                'BackgroundColor', GUI_Msg.BG_COLOR);
        end                
    end
    %% METHODS setters
    % ==================================================================================================================================================
    methods
        function addMessage(this, text, type)
            % Add a message to the logger
            % 
            % INPUT
            %   text    text in HTML format
            %   type    'm'     marked message
            %           'w'     warning message
            %           'e'     error message
            %           otherwise normal
            
            if nargin < 3 || isempty(type)
                type = 'n';
            end
            Core_UI.logMessage(this.jedt, text, type);
        end
        
        function addHTML(this, html_txt)
            % Add a message to the logger
            % 
            % INPUT
            %   text    text in HTML format

            
            Core_UI.logHTML(this.jedt, html_txt);
        end
    end
    
    %% METHODS EVENTS
    % ==================================================================================================================================================
    methods (Access = public)         
    end
end
