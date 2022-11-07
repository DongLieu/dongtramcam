package dongtramcam_test

import (
	"testing"

	keepertest "dongtramcam/testutil/keeper"
	"dongtramcam/testutil/nullify"
	"dongtramcam/x/dongtramcam"
	"dongtramcam/x/dongtramcam/types"
	"github.com/stretchr/testify/require"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.DongtramcamKeeper(t)
	dongtramcam.InitGenesis(ctx, *k, genesisState)
	got := dongtramcam.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
