class_name GameRulesConfig
extends Resource

## Official rules of Los Extintos: El Regreso:
## - Max 3 creatures per side, max hand 5 (discard down to 5 at end of round)
## - Initial Turn: 8/12 Amber & 5 cards; Turn 1+: +4 Amber (cap 12) & +1 card
## - Victory: 3 VP (1 VP per KO)
## - Armor: Flat direct subtraction (damage - armor)
## - Attack order: Strictly fastest to slowest (except Priority abilities)
## - Deck: 15 cards (scalable to 20 in future expansions)

@export var max_board_slots: int = 3
@export var max_hand_size: int = 5
@export var starting_hand_size: int = 5
@export var cards_drawn_per_turn: int = 1

@export var starting_amber: int = 8
@export var amber_per_turn: int = 4
@export var max_amber: int = 12

@export var victory_points_to_win: int = 3
@export var victory_points_per_ko: int = 1

@export var era_advantage_bonus: int = 15
@export var era_disadvantage_penalty: int = -10

@export var min_deck_size: int = 15
@export var max_deck_size: int = 15
@export var max_copies_per_creature: int = 2
