package keeper_test

import (
	"testing"

	testkeeper "dongtramcam/testutil/keeper"
	"dongtramcam/x/dongtramcam/types"
	"github.com/stretchr/testify/require"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.DongtramcamKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
