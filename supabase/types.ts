export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          operationName?: string
          query?: string
          variables?: Json
          extensions?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      auth_game: {
        Row: {
          auth_uid: string
          player_id: number
        }
        Insert: {
          auth_uid: string
          player_id: number
        }
        Update: {
          auth_uid?: string
          player_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "auth_game_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: true
            referencedRelation: "game_players"
            referencedColumns: ["id"]
          },
        ]
      }
      auth_lobby: {
        Row: {
          auth_uid: string
          player_id: number
        }
        Insert: {
          auth_uid: string
          player_id: number
        }
        Update: {
          auth_uid?: string
          player_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "auth_lobby_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: true
            referencedRelation: "lobby_players"
            referencedColumns: ["id"]
          },
        ]
      }
      game_fields: {
        Row: {
          field_value: number | null
          game_id: number | null
          id: number
          x: number
          y: number
        }
        Insert: {
          field_value?: number | null
          game_id?: number | null
          id?: number
          x: number
          y: number
        }
        Update: {
          field_value?: number | null
          game_id?: number | null
          id?: number
          x?: number
          y?: number
        }
        Relationships: [
          {
            foreignKeyName: "game_fields_game_id_fkey"
            columns: ["game_id"]
            isOneToOne: false
            referencedRelation: "games"
            referencedColumns: ["id"]
          },
        ]
      }
      game_players: {
        Row: {
          game_id: number | null
          id: number
          player_number: number
          position_x: number
          position_y: number
        }
        Insert: {
          game_id?: number | null
          id?: number
          player_number: number
          position_x: number
          position_y: number
        }
        Update: {
          game_id?: number | null
          id?: number
          player_number?: number
          position_x?: number
          position_y?: number
        }
        Relationships: [
          {
            foreignKeyName: "game_players_game_id_fkey"
            columns: ["game_id"]
            isOneToOne: false
            referencedRelation: "games"
            referencedColumns: ["id"]
          },
        ]
      }
      games: {
        Row: {
          created_at: string
          current_player_number: number
          ended_at: string | null
          id: number
          size_x: number
          size_y: number
        }
        Insert: {
          created_at?: string
          current_player_number?: number
          ended_at?: string | null
          id?: number
          size_x: number
          size_y: number
        }
        Update: {
          created_at?: string
          current_player_number?: number
          ended_at?: string | null
          id?: number
          size_x?: number
          size_y?: number
        }
        Relationships: []
      }
      lobbies: {
        Row: {
          created_at: string
          ended_at: string | null
          id: string
        }
        Insert: {
          created_at?: string
          ended_at?: string | null
          id?: string
        }
        Update: {
          created_at?: string
          ended_at?: string | null
          id?: string
        }
        Relationships: []
      }
      lobby_game: {
        Row: {
          created_at: string
          game_id: number
          lobby_id: string
        }
        Insert: {
          created_at?: string
          game_id: number
          lobby_id: string
        }
        Update: {
          created_at?: string
          game_id?: number
          lobby_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "lobby_game_game_id_fkey"
            columns: ["game_id"]
            isOneToOne: true
            referencedRelation: "games"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lobby_game_lobby_id_fkey"
            columns: ["lobby_id"]
            isOneToOne: true
            referencedRelation: "lobbies"
            referencedColumns: ["id"]
          },
        ]
      }
      lobby_players: {
        Row: {
          id: number
          lobby_id: string | null
          player_number: number
        }
        Insert: {
          id?: number
          lobby_id?: string | null
          player_number: number
        }
        Update: {
          id?: number
          lobby_id?: string | null
          player_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "lobby_players_lobby_id_fkey"
            columns: ["lobby_id"]
            isOneToOne: false
            referencedRelation: "lobbies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      auth_game_get_user_games: {
        Args: Record<PropertyKey, never>
        Returns: {
          created_at: string
          current_player_number: number
          ended_at: string | null
          id: number
          size_x: number
          size_y: number
        }[]
      }
      game_generate_board: {
        Args: {
          the_game_id: number
          size_x: number
          size_y: number
          num_field_values: number
        }
        Returns: undefined
      }
      game_generate_player_position_by_number_simple: {
        Args: { the_game_id: number; the_player_number: number }
        Returns: {
          position_x: number
          position_y: number
        }[]
      }
      game_get_players_current_fields_ids: {
        Args: { player_id: number }
        Returns: number[]
      }
      game_play_logic: {
        Args: { the_game_id: number; player_number: number; value: number }
        Returns: undefined
      }
      game_set_next_player: {
        Args: { the_game_id: number; player_number: number }
        Returns: undefined
      }
      get_user_lobby_ids: {
        Args: Record<PropertyKey, never>
        Returns: string[]
      }
      lobby_game_create_players: {
        Args: { the_lobby_id: string }
        Returns: number[]
      }
      lobby_player_join: {
        Args: { the_lobby_id: string }
        Returns: number
      }
      lobby_player_leave: {
        Args: { the_lobby_id: string; the_player_id: number }
        Returns: undefined
      }
      user_create_lobby: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      user_game_player_play: {
        Args: { the_game_id: number; value: number }
        Returns: undefined
      }
      user_get_game_player: {
        Args: { the_game_id: number }
        Returns: {
          game_id: number | null
          id: number
          player_number: number
          position_x: number
          position_y: number
        }
      }
      user_join_lobby: {
        Args: { the_lobby_id: string }
        Returns: number
      }
      user_leave_lobby: {
        Args: { the_lobby_id: string }
        Returns: undefined
      }
      user_lobby_start_game: {
        Args: { the_lobby_id: string }
        Returns: number
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DefaultSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof (Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? (Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const

